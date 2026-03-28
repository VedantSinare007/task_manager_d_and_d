import asyncio
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.repositories.task_repo import task_repo
from app.models.task import Task, TaskStatus
from app.schemas.task import TaskCreate, TaskUpdate, TaskResponse
from typing import Optional, List


def _compute_is_blocked(task: Task, db: Session) -> bool:
    """A task is actively blocked if its blocker exists and is NOT done."""
    if task.blocked_by_id is None:
        return False
    blocker = task_repo.get_by_id(db, task.blocked_by_id)
    if blocker is None:
        return False
    return blocker.status != TaskStatus.done


def _to_response(task: Task, db: Session) -> TaskResponse:
    return TaskResponse(
        id=task.id,
        title=task.title,
        description=task.description,
        due_date=task.due_date,
        status=task.status,
        blocked_by_id=task.blocked_by_id,
        order_index=task.order_index,
        created_at=task.created_at,
        updated_at=task.updated_at,
        is_blocked=_compute_is_blocked(task, db),
    )


class TaskService:

    def get_all(
        self,
        db: Session,
        search: Optional[str] = None,
        status: Optional[TaskStatus] = None,
    ) -> List[TaskResponse]:
        tasks = task_repo.get_all(db, search=search, status=status)
        return [_to_response(t, db) for t in tasks]

    def get_by_id(self, db: Session, task_id: int) -> TaskResponse:
        task = task_repo.get_by_id(db, task_id)
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Task {task_id} not found",
            )
        return _to_response(task, db)

    async def create(self, db: Session, data: TaskCreate) -> TaskResponse:
        self._validate_blocked_by(db, data.blocked_by_id, exclude_id=None)
        # Simulate 2-second backend processing delay
        await asyncio.sleep(2)
        task = task_repo.create(db, data)
        return _to_response(task, db)

    async def update(self, db: Session, task_id: int, data: TaskUpdate) -> TaskResponse:
        task = task_repo.get_by_id(db, task_id)
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Task {task_id} not found",
            )
        self._validate_blocked_by(db, data.blocked_by_id, exclude_id=task_id)
        # Simulate 2-second backend processing delay
        await asyncio.sleep(2)
        updated = task_repo.update(db, task, data)
        return _to_response(updated, db)

    def delete(self, db: Session, task_id: int) -> None:
        task = task_repo.get_by_id(db, task_id)
        if not task:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Task {task_id} not found",
            )
        task_repo.delete(db, task)

    def reorder(self, db: Session, ordered_ids: List[int]) -> List[TaskResponse]:
        # Validate all IDs exist
        for task_id in ordered_ids:
            if not task_repo.get_by_id(db, task_id):
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail=f"Task {task_id} not found during reorder",
                )
        tasks = task_repo.reorder(db, ordered_ids)
        return [_to_response(t, db) for t in tasks]

    def _validate_blocked_by(
        self, db: Session, blocked_by_id: Optional[int], exclude_id: Optional[int]
    ) -> None:
        if blocked_by_id is None:
            return
        if blocked_by_id == exclude_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A task cannot block itself",
            )
        blocker = task_repo.get_by_id(db, blocked_by_id)
        if not blocker:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Blocking task {blocked_by_id} not found",
            )


task_service = TaskService()