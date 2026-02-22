import uuid
from faker import Faker
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.models.user import User
from app.models.profile import Profile

fake = Faker()


def get_or_create_user_by_phone(db: Session, phone: str) -> User:
    user = db.query(User).filter(User.phone == phone).first()
    if user:
        return user

    user = User(
        id=str(uuid.uuid4()),
        phone=phone,
        is_verified=True,
        is_banned=False,
    )
    db.add(user)
    db.flush()  # 👈 ensures user.id exists in DB
    return user


def seed(db: Session, count: int = 40):
    users: list[User] = []

    # 1️⃣ Create users first
    for _ in range(count):
        phone = f"+91{fake.random_number(digits=10, fix_len=True)}"
        user = get_or_create_user_by_phone(db, phone)
        users.append(user)

    db.flush()  # 👈 all users now exist

    # 2️⃣ Create profiles linked to users
    for user in users:
        profile = Profile(
            user_id=user.id,
            name=fake.first_name(),
            birth_year=fake.random_int(min=1990, max=2005),
            gender=fake.random_element(["male", "female", "nonbinary"]),
            intent=fake.random_element(["dating", "friends", "marriage"]),
            bio=fake.text(max_nb_chars=200),
            city=fake.city(),
            lat=28.6 + fake.random.uniform(-0.1, 0.1),
            lng=77.2 + fake.random.uniform(-0.1, 0.1),
            pref_gender=None,
        )
        db.add(profile)

    db.commit()


if __name__ == "__main__":
    db = SessionLocal()
    try:
        seed(db)
        print("✅ Seed data created successfully")
    finally:
        db.close()
