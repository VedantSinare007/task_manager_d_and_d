from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.task import Task, TaskStatus
from app.schemas.task import TaskCreate, TaskUpdate
from typing import Optional, List


class TaskRepository:

    def get_all(
        self,
        db: Session,
        search: Optional[str] = None,
        status: Optional[TaskStatus] = None,
    ) -> List[Task]:
        query = db.query(Task)
        if search:
            query = query.filter(Task.title.ilike(f"%{search}%"))
        if status:
            query = query.filter(Task.status == status)
        return query.order_by(Task.order_index.asc(), Task.created_at.asc()).all()

    def get_by_id(self, db: Session, task_id: int) -> Optional[Task]:
        return db.query(Task).filter(Task.id == task_id).first()

    def create(self, db: Session, data: TaskCreate) -> Task:
        # Assign the next order_index (append to end of list)
        max_order = db.query(func.max(Task.order_index)).scalar() or 0
        task = Task(
            title=data.title,
            description=data.description,
            due_date=data.due_date,
            status=data.status,
            blocked_by_id=data.blocked_by_id,
            order_index=max_order + 1,
        )
        db.add(task)
        db.commit()
        db.refresh(task)
        return task

    def update(self, db: Session, task: Task, data: TaskUpdate) -> Task:
        task.title = data.title
        task.description = data.description
        task.due_date = data.due_date
        task.status = data.status
        task.blocked_by_id = data.blocked_by_id
        db.commit()
        db.refresh(task)
        return task

    def delete(self, db: Session, task: Task) -> None:
        # Clear blocked_by references to this task before deleting
        db.query(Task).filter(Task.blocked_by_id == task.id).update(
            {"blocked_by_id": None}
        )
        db.delete(task)
        db.commit()

    def reorder(self, db: Session, ordered_ids: List[int]) -> List[Task]:
        for index, task_id in enumerate(ordered_ids):
            db.query(Task).filter(Task.id == task_id).update(
                {"order_index": index}
            )
        db.commit()
        return self.get_all(db)


task_repo = TaskRepository()