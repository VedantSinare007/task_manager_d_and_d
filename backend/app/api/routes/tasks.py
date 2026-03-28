from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional, List
from app.db.database import get_db
from app.services.task_service import task_service
from app.schemas.task import TaskCreate, TaskUpdate, TaskResponse, ReorderRequest, TaskListResponse
from app.models.task import TaskStatus

router = APIRouter()


@router.get("", response_model=TaskListResponse)
def get_tasks(
    search: Optional[str] = Query(None, description="Search by title"),
    status: Optional[TaskStatus] = Query(None, description="Filter by status"),
    db: Session = Depends(get_db),
):
    tasks = task_service.get_all(db, search=search, status=status)
    return TaskListResponse(tasks=tasks, total=len(tasks))


@router.get("/{task_id}", response_model=TaskResponse)
def get_task(task_id: int, db: Session = Depends(get_db)):
    return task_service.get_by_id(db, task_id)


@router.post("", response_model=TaskResponse, status_code=201)
async def create_task(data: TaskCreate, db: Session = Depends(get_db)):
    return await task_service.create(db, data)


@router.put("/{task_id}", response_model=TaskResponse)
async def update_task(task_id: int, data: TaskUpdate, db: Session = Depends(get_db)):
    return await task_service.update(db, task_id, data)


@router.delete("/{task_id}", status_code=204)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task_service.delete(db, task_id)


@router.patch("/reorder", response_model=List[TaskResponse])
def reorder_tasks(data: ReorderRequest, db: Session = Depends(get_db)):
    return task_service.reorder(db, data.ordered_ids)