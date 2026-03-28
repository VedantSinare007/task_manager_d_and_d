from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import date, datetime
from app.models.task import TaskStatus


class TaskBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str = Field(default="", max_length=2000)
    due_date: Optional[date] = None
    status: TaskStatus = TaskStatus.todo
    blocked_by_id: Optional[int] = None


class TaskCreate(TaskBase):
    pass


class TaskUpdate(TaskBase):
    pass


class TaskResponse(TaskBase):
    id: int
    order_index: int
    created_at: datetime
    updated_at: datetime
    is_blocked: bool = False  # computed: blocked_by task is not "Done"

    class Config:
        from_attributes = True


class ReorderRequest(BaseModel):
    ordered_ids: List[int] = Field(..., description="Task IDs in the new desired order")


class TaskListResponse(BaseModel):
    tasks: List[TaskResponse]
    total: int