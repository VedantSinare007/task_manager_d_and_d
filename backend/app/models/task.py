from sqlalchemy import Column, Integer, String, Date, Enum, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.db.database import Base
import enum
from datetime import datetime


class TaskStatus(str, enum.Enum):
    todo = "To-Do"
    in_progress = "In Progress"
    done = "Done"


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(255), nullable=False)
    description = Column(String(2000), nullable=False, default="")
    due_date = Column(Date, nullable=True)
    status = Column(Enum(TaskStatus), nullable=False, default=TaskStatus.todo)
    blocked_by_id = Column(Integer, ForeignKey("tasks.id", ondelete="SET NULL"), nullable=True)
    order_index = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Self-referential relationship: a task can be blocked by another task
    blocked_by = relationship("Task", remote_side=[id], foreign_keys=[blocked_by_id])