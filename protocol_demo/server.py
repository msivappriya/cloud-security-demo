from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from sqlalchemy.exc import IntegrityError
import uvicorn

from db import CRP, session_scope


app = FastAPI()


class UserModel(BaseModel):
    name: str
    crps: dict[str, str] = Field(default_factory=dict)


class ResponseModel(BaseModel):
    message: str


@app.post("/enrol")
def enrol(user: UserModel) -> ResponseModel:
    with session_scope() as session:
        try:
            session.add_all(
                [
                    CRP(
                        user=user.name,
                        challenge=key,
                        response=val
                    ) for key, val in user.crps.items()
                ]
            )
        except IntegrityError:
            raise HTTPException(403, f"User `user.name` already exists")

    return ResponseModel(message=f"`{user.name}` enroled successfully")


@app.post("/authenticate")
def authenticate(user: UserModel) -> ResponseModel:
    with session_scope() as session:
        crps = {
            str(crp.challenge): str(crp.response)
            for crp in session.query(CRP).filter_by(user=user.name).all()
        }
        if not crps:
            raise HTTPException(404, f"User `{user.name}` not found.")

        for key, val in user.crps.items():
            try:
                if crps[key] != val:
                    raise HTTPException(401, "Auth failed")
            except KeyError:
                raise HTTPException(404, f"Challenge `{key}` not found")

    return ResponseModel(message="Auth Success")


if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
