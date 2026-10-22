#!/usr/bin/env python3
"""Local sign-in API for habitdb. Flutter calls this; the browser cannot open SQL Server."""

import datetime
import json
import os
import uuid
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import bcrypt
import pytds

HOST = "127.0.0.1"
PORT = 8787


def load_settings():
    path = os.path.join(os.path.dirname(__file__), "db.env")
    values = {}
    if os.path.exists(path):
        with open(path, encoding="utf-8") as handle:
            for line in handle:
                line = line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, value = line.split("=", 1)
                values[key.strip()] = value.strip()

    def setting(key, default=""):
        return os.environ.get(key, values.get(key, default))

    return {
        "server": setting("SQL_SERVER", "localhost"),
        "port": int(setting("SQL_PORT", "1433")),
        "database": setting("SQL_DATABASE", "habitdb"),
        "user": setting("SQL_USER", "sa"),
        "password": setting("SQL_PASSWORD", ""),
    }


SETTINGS = load_settings()


def password_matches(stored, given):
    stored_text = "" if stored is None else str(stored)
    given_bytes = given.encode("utf-8")
    stored_bytes = stored_text.encode("utf-8")
    if stored_text.startswith(("$2a$", "$2b$", "$2y$")):
        try:
            return bcrypt.checkpw(given_bytes, stored_bytes)
        except ValueError:
            return False
    if len(stored_bytes) != len(given_bytes):
        return False
    mismatch = 0
    for left, right in zip(stored_bytes, given_bytes):
        mismatch |= left ^ right
    return mismatch == 0 and stored_text != ""


def connect():
    if not SETTINGS["password"]:
        raise RuntimeError(
            "Set SQL_PASSWORD in server/db.env, then restart this API."
        )
    return pytds.connect(
        SETTINGS["server"],
        SETTINGS["database"],
        SETTINGS["user"],
        SETTINGS["password"],
        port=SETTINGS["port"],
        autocommit=True,
        login_timeout=5,
        timeout=5,
    )


def find_user(email, password):
    with connect() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT TOP 1 name, email, password_hash
                FROM dbo.users
                WHERE LOWER(email) = LOWER(%s)
                """,
                (email,),
            )
            row = cursor.fetchone()

    if row is None or not password_matches(row[2], password):
        return None
    return {"name": row[0], "email": row[1]}


def create_user(name, email, password):
    password_hash = bcrypt.hashpw(
        password.encode("utf-8"), bcrypt.gensalt()
    ).decode("utf-8")

    with connect() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT TOP 1 1
                FROM dbo.users
                WHERE LOWER(email) = LOWER(%s)
                """,
                (email,),
            )
            if cursor.fetchone() is not None:
                raise ValueError("An account with this email already exists.")

            cursor.execute(
                """
                INSERT INTO dbo.users (
                  id, name, email, password_hash, terms_accepted_at, created_at, updated_at
                )
                VALUES (%s, %s, %s, %s, SYSUTCDATETIME(), SYSUTCDATETIME(), SYSUTCDATETIME())
                """,
                (str(uuid.uuid4()), name, email, password_hash),
            )

    return {"name": name, "email": email}


def update_name(email, name):
    with connect() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE dbo.users
                SET name = %s, updated_at = SYSUTCDATETIME()
                WHERE LOWER(email) = LOWER(%s)
                """,
                (name, email),
            )
            if cursor.rowcount == 0:
                raise ValueError("No account was found for this email.")
    return {"name": name, "email": email}


def user_id_for(email):
    with connect() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT TOP 1 id
                FROM dbo.users
                WHERE LOWER(email) = LOWER(%s)
                """,
                (email,),
            )
            row = cursor.fetchone()
    if row is None:
        raise ValueError("No account was found for this email.")
    return str(row[0])


def _as_bool(value):
    return bool(value)


def _time_text(value):
    if value is None:
        return None
    return value.strftime("%H:%M:%S")


def _date_text(value):
    return value.strftime("%Y-%m-%d")


def _clock_text(value):
    if value is None:
        return None
    return value.strftime("%H:%M")


def _parse_time(value):
    if not value:
        return None
    hour, minute = str(value).split(":")[:2]
    return datetime.time(int(hour), int(minute))


def _habit_json(row, logs):
    return {
        "id": str(row[0]),
        "name": row[1],
        "description": row[2] or "",
        "dailyGoal": int(row[3]),
        "unit": row[4],
        "weekdays": [_as_bool(row[index]) for index in range(5, 12)],
        "reminderEnabled": _as_bool(row[12]),
        "reminderTime": _time_text(row[13]),
        "logs": logs,
    }


def list_habits(email):
    owner = user_id_for(email)
    with connect() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT id, name, description, daily_goal, goal_unit,
                  repeat_monday, repeat_tuesday, repeat_wednesday, repeat_thursday,
                  repeat_friday, repeat_saturday, repeat_sunday,
                  reminder_enabled, reminder_time
                FROM dbo.habits
                WHERE user_id = %s
                ORDER BY created_at
                """,
                (owner,),
            )
            habit_rows = cursor.fetchall()
            cursor.execute(
                """
                SELECT l.habit_id, l.log_date, l.amount, l.completed_at
                FROM dbo.habit_logs l
                INNER JOIN dbo.habits h ON h.id = l.habit_id
                WHERE h.user_id = %s
                """,
                (owner,),
            )
            log_rows = cursor.fetchall()

    grouped = {}
    for habit_id, log_date, amount, completed_at in log_rows:
        grouped.setdefault(str(habit_id), []).append(
            {
                "date": _date_text(log_date),
                "amount": int(amount),
                "completedAt": _clock_text(completed_at),
            }
        )
    return [_habit_json(row, grouped.get(str(row[0]), [])) for row in habit_rows]


def _weekday_flags(days):
    flags = [bool(day) for day in days]
    if len(flags) != 7:
        raise ValueError("Choose the days this habit repeats.")
    return flags


def save_habit(email, data, habit_id=None):
    owner = user_id_for(email)
    name = str(data.get("name", "")).strip()
    description = str(data.get("description", "")).strip() or None
    daily_goal = int(data.get("dailyGoal") or 0)
    unit = str(data.get("unit", "")).strip()
    weekdays = _weekday_flags(data.get("weekdays") or [])
    reminder_enabled = bool(data.get("reminderEnabled"))
    reminder_time = _parse_time(data.get("reminderTime")) if reminder_enabled else None
    if not name or daily_goal < 1 or not unit:
        raise ValueError("Enter a name, goal, and unit.")
    if reminder_enabled and reminder_time is None:
        raise ValueError("Choose a reminder time.")

    with connect() as connection:
        with connection.cursor() as cursor:
            if habit_id is None:
                habit_id = str(uuid.uuid4())
                cursor.execute(
                    """
                    INSERT INTO dbo.habits (
                      id, user_id, name, description, daily_goal, goal_unit,
                      repeat_monday, repeat_tuesday, repeat_wednesday, repeat_thursday,
                      repeat_friday, repeat_saturday, repeat_sunday,
                      reminder_enabled, reminder_time, created_at, updated_at
                    )
                    VALUES (
                      %s, %s, %s, %s, %s, %s,
                      %s, %s, %s, %s, %s, %s, %s,
                      %s, %s, SYSUTCDATETIME(), SYSUTCDATETIME()
                    )
                    """,
                    (
                        habit_id,
                        owner,
                        name,
                        description,
                        daily_goal,
                        unit,
                        *weekdays,
                        reminder_enabled,
                        reminder_time,
                    ),
                )
            else:
                cursor.execute(
                    """
                    UPDATE dbo.habits
                    SET name = %s, description = %s, daily_goal = %s, goal_unit = %s,
                      repeat_monday = %s, repeat_tuesday = %s, repeat_wednesday = %s,
                      repeat_thursday = %s, repeat_friday = %s, repeat_saturday = %s,
                      repeat_sunday = %s, reminder_enabled = %s, reminder_time = %s,
                      updated_at = SYSUTCDATETIME()
                    WHERE id = %s AND user_id = %s
                    """,
                    (
                        name,
                        description,
                        daily_goal,
                        unit,
                        *weekdays,
                        reminder_enabled,
                        reminder_time,
                        habit_id,
                        owner,
                    ),
                )
                if cursor.rowcount == 0:
                    raise ValueError("That habit was not found.")

    saved = list_habits(email)
    for habit in saved:
        if habit["id"].lower() == habit_id.lower():
            return habit
    raise ValueError("That habit was not found.")


def delete_habit(email, habit_id):
    owner = user_id_for(email)
    with connect() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                DELETE FROM dbo.habits
                WHERE id = %s AND user_id = %s
                """,
                (habit_id, owner),
            )
            if cursor.rowcount == 0:
                raise ValueError("That habit was not found.")


def save_log(email, habit_id, log_date, amount):
    owner = user_id_for(email)
    amount = int(amount)
    with connect() as connection:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                SELECT daily_goal
                FROM dbo.habits
                WHERE id = %s AND user_id = %s
                """,
                (habit_id, owner),
            )
            row = cursor.fetchone()
            if row is None:
                raise ValueError("That habit was not found.")
            goal = int(row[0])
            cursor.execute(
                """
                DELETE FROM dbo.habit_logs
                WHERE habit_id = %s AND log_date = %s
                """,
                (habit_id, log_date),
            )
            if amount > 0:
                cursor.execute(
                    """
                    INSERT INTO dbo.habit_logs (id, habit_id, log_date, amount, completed_at)
                    VALUES (%s, %s, %s, %s, CASE WHEN %s >= %s THEN SYSUTCDATETIME() ELSE NULL END)
                    """,
                    (str(uuid.uuid4()), habit_id, log_date, amount, amount, goal),
                )


class Handler(BaseHTTPRequestHandler):
    def _send(self, status, body):
        payload = json.dumps(body).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.send_header("Access-Control-Allow-Methods", "POST, OPTIONS")
        self.end_headers()
        self.wfile.write(payload)

    def do_OPTIONS(self):
        self._send(204, {})

    def _read_json(self):
        length = int(self.headers.get("Content-Length", "0"))
        try:
            return json.loads(self.rfile.read(length) or b"{}")
        except json.JSONDecodeError:
            return None

    def do_POST(self):
        data = self._read_json()
        if data is None:
            self._send(400, {"message": "Send a JSON body."})
            return

        if self.path == "/sign-in":
            self._sign_in(data)
            return
        if self.path == "/create-account":
            self._create_account(data)
            return
        if self.path == "/update-name":
            self._update_name(data)
            return
        if self.path == "/habits/list":
            self._habits_list(data)
            return
        if self.path == "/habits/save":
            self._habits_save(data)
            return
        if self.path == "/habits/delete":
            self._habits_delete(data)
            return
        if self.path == "/habits/log":
            self._habits_log(data)
            return
        self._send(404, {"message": "Not found."})

    def _sign_in(self, data):
        email = str(data.get("email", "")).strip()
        password = str(data.get("password", ""))
        if not email or not password:
            self._send(400, {"message": "Enter your email and password."})
            return

        try:
            user = find_user(email, password)
        except Exception as error:
            self._send(503, {"message": str(error)})
            return

        if user is None:
            self._send(401, {"message": "Email or password is incorrect."})
            return
        self._send(200, user)

    def _create_account(self, data):
        name = str(data.get("name", "")).strip()
        email = str(data.get("email", "")).strip()
        password = str(data.get("password", ""))
        if not name or not email or not password:
            self._send(400, {"message": "Enter your name, email, and password."})
            return

        try:
            user = create_user(name, email, password)
        except ValueError as error:
            self._send(409, {"message": str(error)})
            return
        except Exception as error:
            self._send(503, {"message": str(error)})
            return
        self._send(201, user)

    def _update_name(self, data):
        name = str(data.get("name", "")).strip()
        email = str(data.get("email", "")).strip()
        if not name or not email:
            self._send(400, {"message": "Enter your name."})
            return
        try:
            user = update_name(email, name)
        except ValueError as error:
            self._send(404, {"message": str(error)})
            return
        except Exception as error:
            self._send(503, {"message": str(error)})
            return
        self._send(200, user)

    def _email(self, data):
        return str(data.get("email", "")).strip()

    def _habits_list(self, data):
        email = self._email(data)
        if not email:
            self._send(400, {"message": "Sign in again to load habits."})
            return
        try:
            self._send(200, {"habits": list_habits(email)})
        except ValueError as error:
            self._send(404, {"message": str(error)})
        except Exception as error:
            self._send(503, {"message": str(error)})

    def _habits_save(self, data):
        email = self._email(data)
        habit_id = str(data.get("id", "")).strip() or None
        if not email:
            self._send(400, {"message": "Sign in again to save this habit."})
            return
        try:
            self._send(200, save_habit(email, data, habit_id))
        except ValueError as error:
            self._send(400, {"message": str(error)})
        except Exception as error:
            self._send(503, {"message": str(error)})

    def _habits_delete(self, data):
        email = self._email(data)
        habit_id = str(data.get("id", "")).strip()
        if not email or not habit_id:
            self._send(400, {"message": "That habit could not be deleted."})
            return
        try:
            delete_habit(email, habit_id)
        except ValueError as error:
            self._send(404, {"message": str(error)})
            return
        except Exception as error:
            self._send(503, {"message": str(error)})
            return
        self._send(200, {"ok": True})

    def _habits_log(self, data):
        email = self._email(data)
        habit_id = str(data.get("habitId", "")).strip()
        log_date = str(data.get("date", "")).strip()
        if not email or not habit_id or not log_date:
            self._send(400, {"message": "That check-in could not be saved."})
            return
        try:
            save_log(email, habit_id, log_date, data.get("amount") or 0)
        except ValueError as error:
            self._send(400, {"message": str(error)})
            return
        except Exception as error:
            self._send(503, {"message": str(error)})
            return
        self._send(200, {"ok": True})

    def log_message(self, format, *args):
        return


if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"Sign-in API listening on http://{HOST}:{PORT}")
    server.serve_forever()
