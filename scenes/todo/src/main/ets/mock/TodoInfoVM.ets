@ObservedV2
export class AddTodoVM {
  @Trace title: string = ''
  @Trace selectedTime: Date = new Date()
  @Trace repetitionType: number = 0
  @Trace reminderType: number = 0
  @Trace repetitionMultiType: number[] = [];
  @Trace priorityType: number = 0
  private static _instance: AddTodoVM
  
  public static get instance() {
    if (!AddTodoVM._instance) {
      AddTodoVM._instance = new AddTodoVM()
    }
    return AddTodoVM._instance
  }
}

@ObservedV2
export class UpdateTodoPlanTimeVM {
  @Trace deleteTaskID: string = ''
  @Trace modifyTaskID: string = ''
  @Trace modifyPlanTime: Date = new Date()
  private static _instance: UpdateTodoPlanTimeVM

  static get instance() {
    if (!UpdateTodoPlanTimeVM._instance) {
      UpdateTodoPlanTimeVM._instance = new UpdateTodoPlanTimeVM();
    }
    return UpdateTodoPlanTimeVM._instance;
  }
}