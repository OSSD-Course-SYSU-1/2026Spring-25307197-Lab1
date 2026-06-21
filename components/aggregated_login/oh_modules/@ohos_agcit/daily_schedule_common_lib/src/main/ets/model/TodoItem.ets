import rpc from '@ohos.rpc';

@ObservedV2
export class TodoItem implements rpc.Parcelable {
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

  // 序列化方法：将对象数据写入MessageSequence
  marshalling(messageSequence: rpc.MessageSequence): boolean {
    messageSequence.writeString(this.taskID);
    messageSequence.writeString(this.title);
    messageSequence.writeLong(this.planTime.getTime()); // Date转换为时间戳
    messageSequence.writeInt(this.repetitionType);
    messageSequence.writeInt(this.reminderType);
    messageSequence.writeInt(this.priorityType);
    messageSequence.writeBoolean(this.isFinished);
    return true;
  }

  // 反序列化方法：从MessageSequence读取数据还原对象
  unmarshalling(messageSequence: rpc.MessageSequence): boolean {
    this.taskID = messageSequence.readString();
    this.title = messageSequence.readString();
    this.planTime = new Date(messageSequence.readLong()); // 时间戳转换回Date
    this.repetitionType = messageSequence.readInt();
    this.reminderType = messageSequence.readInt();
    this.priorityType = messageSequence.readInt();
    this.isFinished = messageSequence.readBoolean();
    return true;
  }
}