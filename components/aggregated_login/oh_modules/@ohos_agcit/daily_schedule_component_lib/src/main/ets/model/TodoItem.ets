@ObservedV2
export class TodoItem {
  @Trace taskID: string;
  @Trace title: string;
  @Trace planTime: Date;
  @Trace repetitionType: number;
  @Trace reminderType: number;
  @Trace priorityType: number;
  @Trace isFinished: boolean;

  constructor(taskID: string, title: string, planTime: Date, repetitionType: number, reminderType: number,
    priority: number, isFinished: boolean) {
    this.taskID = taskID;
    this.title = title;
    this.planTime = planTime;
    this.repetitionType = repetitionType;
    this.reminderType = reminderType;
    this.priorityType = priority;
    this.isFinished = isFinished;
  }
}