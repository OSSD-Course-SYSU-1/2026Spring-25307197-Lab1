@ObservedV2
export class TodoListTabInfo {
  @Trace statusIndex: number = 0
  @Trace priorityIndex: number = 0
  private static _instance: FilterInfo

  static get instance() {
    if (!TodoListTabInfo._instance) {
      TodoListTabInfo._instance = new FilterInfo();
    }
    return TodoListTabInfo._instance;
  }
}

@ObservedV2
export class FilterInfo {
  @Trace statusIndex: number = 0
  @Trace priorityIndex: number = 0
  private static _instance: FilterInfo

  static get instance() {
    if (!FilterInfo._instance) {
      FilterInfo._instance = new FilterInfo();
    }
    return FilterInfo._instance;
  }
}

@ObservedV2
export class ExtInfo {
  @Trace isShowFinished: boolean = true
  // true降序 false升序
  @Trace isDescending: boolean = true
  private static _instance: ExtInfo

  static get instance() {
    if (!ExtInfo._instance) {
      ExtInfo._instance = new ExtInfo();
    }
    return ExtInfo._instance;
  }
}