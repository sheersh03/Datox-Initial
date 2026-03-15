import uuid
from datetime import datetime, timezone
from faker import Faker
from sqlalchemy.orm import Session

from app.db.session import SessionLocal
from app.models.prompt import Prompt
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


def _round_loc(value: float, km: float = 2.0) -> float:
    step = km / 111.0
    return round(value / step) * step


def _compatible_birth_year(age_min: int, age_max: int, offset: int) -> int:
    year = datetime.now(timezone.utc).year
    oldest = year - int(age_max)
    youngest = year - int(age_min)
    span = max(youngest - oldest, 0)
    return oldest + (offset % (span + 1))


def seed_discovery_candidates(
    db: Session,
    *,
    target_user_id: str,
    count: int = 24,
) -> int:
    me = db.query(Profile).filter(Profile.user_id == target_user_id).first()
    if not me:
        raise ValueError(f"Profile not found for user_id={target_user_id}")
    if me.lat is None or me.lng is None:
        raise ValueError(f"Profile {target_user_id} is missing location")

    pref_genders = [g.strip() for g in (me.pref_gender or "").split(",") if g.strip()]
    gender_pool = pref_genders or [me.gender]
    distance_span = max(float(me.distance_km) * 0.45, 0.8)
    questions = [
        "What makes a night memorable for you?",
        "What are you optimistically building in life right now?",
        "How do you spend an unexpectedly free Sunday?",
    ]

    created = 0
    base_index = (
        db.query(Profile)
        .filter(Profile.user_id.like(f"seed-{target_user_id}-%"))
        .count()
    )

    for i in range(count):
        idx = base_index + i + 1
        user_id = f"seed-{target_user_id}-{idx}"
        phone = f"+1999{idx:06d}{(idx % 10)}"
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            user = User(
                id=user_id,
                phone=phone,
                is_verified=True,
                is_banned=False,
                profile_completed=True,
            )
            db.add(user)
            db.flush()

        lat_offset = ((i % 6) - 2.5) * (distance_span / 111.0 / 3.0)
        lng_offset = ((i % 5) - 2.0) * (distance_span / 111.0 / 3.0)
        profile = db.query(Profile).filter(Profile.user_id == user_id).first()
        if not profile:
            profile = Profile(user_id=user_id)
            db.add(profile)

        profile.name = fake.first_name()
        profile.birth_year = _compatible_birth_year(me.age_min, me.age_max, idx)
        profile.gender = gender_pool[i % len(gender_pool)]
        profile.intent = me.intent
        profile.bio = fake.sentence(nb_words=18)
        profile.city = me.city or "Mountain View"
        profile.lat = float(me.lat) + lat_offset
        profile.lng = float(me.lng) + lng_offset
        profile.approx_lat = _round_loc(profile.lat)
        profile.approx_lng = _round_loc(profile.lng)
        profile.age_min = me.age_min
        profile.age_max = me.age_max
        profile.distance_km = max(me.distance_km, 25)
        profile.pref_gender = me.gender
        profile.verification_status = "unverified"
        created += 1

        has_prompt = (
            db.query(Prompt.id)
            .filter(Prompt.user_id == user_id)
            .first()
        )
        if not has_prompt:
            db.add(
                Prompt(
                    id=str(uuid.uuid4()),
                    user_id=user_id,
                    question=questions[i % len(questions)],
                    answer=fake.sentence(nb_words=14),
                    order=0,
                )
            )

    db.commit()
    return created


if __name__ == "__main__":
    db = SessionLocal()
    try:
        seed(db)
        print("✅ Seed data created successfully")
    finally:
        db.close()
