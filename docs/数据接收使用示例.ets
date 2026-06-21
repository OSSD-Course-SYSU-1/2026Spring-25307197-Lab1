/**
 * 待办数据接收和自动解析使用示例
 * 
 * 本示例展示如何使用TodoDataReceiver接收、解析和自动插入待办数据
 */

import { TodoDataReceiver, TodoAction, TodoDataFormat } from '@ohos_agcit/daily_schedule_common_lib';
import { TodoDataManager, TodoPersistenceWrapper } from '@ohos_agcit/daily_schedule_todo';

// 示例1: 基本的数据接收和解析
function example1_BasicDataReceive() {
  const receiver = TodoDataReceiver.instance;
  
  // 模拟接收到的JSON数据
  const receivedJsonData = JSON.stringify({
    title: '完成项目报告',
    planTime: Date.now() + 86400000, // 明天
    priorityType: 2, // 中优先级
    reminderType: 1 // 提前1天提醒
  });
  
  // 解析和验证数据
  const data: TodoDataFormat | null = receiver.parseAndValidate(receivedJsonData);
  
  if (data) {
    console.log('数据解析成功:', data.title);
    
    // 转换为TodoItem对象（自动生成ID）
    const todoItem = receiver.convertToTodoItem(data, true);
    
    // 添加到待办管理器
    TodoDataManager.instance.addTask(todoItem);
    
    console.log('待办已添加并自动保存到数据库');
  } else {
    console.log('数据验证失败');
  }
}

// 示例2: 批量数据导入
function example2_BatchImport() {
  const receiver = TodoDataReceiver.instance;
  const dataManager = TodoDataManager.instance;
  
  // 模拟批量接收的数据
  const batchData = [
    JSON.stringify({
      title: '任务1: 代码审查',
      planTime: Date.now() + 3600000,
      priorityType: 3
    }),
    JSON.stringify({
      title: '任务2: 编写文档',
      planTime: Date.now() + 7200000,
      priorityType: 2
    }),
    JSON.stringify({
      title: '任务3: 测试验证',
      planTime: Date.now() + 10800000,
      priorityType: 1
    })
  ];
  
  // 批量解析
  const results = receiver.batchParse(batchData);
  
  // 处理结果
  let successCount = 0;
  let failCount = 0;
  
  results.forEach((result, index) => {
    if (result.success && result.todoItem) {
      dataManager.addTask(result.todoItem);
      successCount++;
      console.log(`待办${index + 1}导入成功: ${result.todoItem.title}`);
    } else {
      failCount++;
      console.log(`待办${index + 1}导入失败: ${result.message}`);
    }
  });
  
  console.log(`批量导入完成: 成功${successCount}个, 失败${failCount}个`);
}

// 示例3: 处理不同操作类型
function example3_HandleDifferentActions() {
  const receiver = TodoDataReceiver.instance;
  const dataManager = TodoDataManager.instance;
  
  // 新增操作
  const addData = JSON.stringify({
    title: '新增待办事项',
    planTime: Date.now() + 86400000,
    priorityType: 2
  });
  
  const parsedAdd = receiver.parseAndValidate(addData);
  if (parsedAdd) {
    const todoItem = receiver.convertToTodoItem(parsedAdd, true);
    dataManager.addTask(todoItem);
    console.log('新增待办成功');
  }
  
  // 更新操作
  const updateData = JSON.stringify({
    planTime: Date.now() + 172800000, // 改为后天
    isFinished: false
  });
  
  const parsedUpdate = receiver.parseAndValidate(updateData);
  if (parsedUpdate) {
    // 假设已知的taskID
    const taskId = 'existing_task_id';
    
    if (parsedUpdate.planTime) {
      dataManager.updateTaskPlanTime(taskId, new Date(parsedUpdate.planTime));
    }
    
    if (parsedUpdate.isFinished !== undefined) {
      dataManager.updateTaskFinish(taskId, parsedUpdate.isFinished);
    }
    
    console.log('更新待办成功');
  }
  
  // 删除操作
  const taskIdToDelete = 'task_to_delete';
  dataManager.deleteById(taskIdToDelete);
  console.log('删除待办成功');
  
  // 确保保存到数据库
  TodoPersistenceWrapper.save();
}

// 示例4: 创建同步数据包（用于发送）
function example4_CreateSyncPacket() {
  const receiver = TodoDataReceiver.instance;
  
  // 创建一个待办事项
  const todoData: TodoDataFormat = {
    title: '发送给他人的待办',
    planTime: Date.now() + 86400000,
    priorityType: 2,
    reminderType: 1
  };
  
  const todoItem = receiver.convertToTodoItem(todoData, true);
  
  // 创建同步数据包
  const syncPacket = receiver.createSyncDataPacket(TodoAction.ADD, todoItem);
  
  console.log('同步数据包:', syncPacket);
  
  // 这个数据包可以通过分布式数据对象发送到其他设备
  // entryAbility.sendTodoData(TodoAction.ADD, todoItem.taskID, JSON.stringify(todoData));
}

// 示例5: 错误处理和验证
function example5_ErrorHandling() {
  const receiver = TodoDataReceiver.instance;
  
  // 测试无效数据
  const invalidDataCases = [
    // 空标题
    JSON.stringify({
      title: '',
      planTime: Date.now()
    }),
    // 无效的优先级
    JSON.stringify({
      title: '测试待办',
      priorityType: 10 // 超出范围
    }),
    // 无效的时间
    JSON.stringify({
      title: '测试待办',
      planTime: -1 // 无效时间戳
    }),
    // 无效的JSON
    'invalid json string'
  ];
  
  invalidDataCases.forEach((data, index) => {
    const result = receiver.parseAndValidate(data);
    if (result) {
      console.log(`用例${index + 1}: 验证通过`);
    } else {
      console.log(`用例${index + 1}: 验证失败（符合预期）`);
    }
  });
}

// 示例6: 完整的接收处理流程
function example6_CompleteReceiveFlow() {
  const receiver = TodoDataReceiver.instance;
  const dataManager = TodoDataManager.instance;
  
  // 模拟从网络或分布式接收的完整数据包
  const receivedPacket = {
    action: 'add',
    todoId: '',
    todoData: JSON.stringify({
      title: '从其他设备接收的待办',
      planTime: Date.now() + 86400000,
      priorityType: 2,
      repetitionType: 0,
      reminderType: 1,
      isFinished: false
    }),
    timestamp: Date.now(),
    deviceId: 'remote_device_001'
  };
  
  console.log('接收到数据包:', receivedPacket);
  
  // 处理接收到的数据
  if (receivedPacket.action === TodoAction.ADD && receivedPacket.todoData) {
    const data = receiver.parseAndValidate(receivedPacket.todoData);
    
    if (data) {
      const todoItem = receiver.convertToTodoItem(data, true);
      
      // 添加到本地待办列表
      dataManager.addTask(todoItem).then(() => {
        console.log('✓ 待办添加成功');
        console.log(`  标题: ${todoItem.title}`);
        console.log(`  计划时间: ${todoItem.planTime}`);
        console.log(`  优先级: ${todoItem.priorityType}`);
        console.log('✓ 已自动保存到数据库');
      }).catch((err: Error) => {
        console.log('✗ 待办添加失败:', err.message);
      });
    } else {
      console.log('✗ 数据验证失败');
    }
  }
}

// 执行所有示例
export function runAllExamples() {
  console.log('=== 示例1: 基本数据接收 ===');
  example1_BasicDataReceive();
  
  console.log('\n=== 示例2: 批量导入 ===');
  example2_BatchImport();
  
  console.log('\n=== 示例3: 处理不同操作 ===');
  example3_HandleDifferentActions();
  
  console.log('\n=== 示例4: 创建同步数据包 ===');
  example4_CreateSyncPacket();
  
  console.log('\n=== 示例5: 错误处理 ===');
  example5_ErrorHandling();
  
  console.log('\n=== 示例6: 完整接收流程 ===');
  example6_CompleteReceiveFlow();
}
