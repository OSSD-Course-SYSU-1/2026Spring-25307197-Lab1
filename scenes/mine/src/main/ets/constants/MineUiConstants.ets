/**
 * 我的页面-各种服务信息
 */
export interface MinePageCommonService{
  /**
   * 图标
   */
  icon: string,
  /**
   * 标签名称
   */
  label: string,
  /**
   * 跳转到下一页
   */
  nextPage?: string
}

export const COMMON_SERVICE: Array<MinePageCommonService> = [
  {
    icon: 'app.media.app_path',
    label: '意见反馈',
    nextPage: 'FeedBackChoose'
  },
  {
    icon: 'app.media.app_setting',
    label: '设置',
    nextPage: 'Setting'
  }
]