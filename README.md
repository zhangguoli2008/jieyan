# jieyan

本仓库实现了 QuitBuddy V1.0 的核心离线逻辑层 **QuitBuddyKit**（Swift Package），覆盖需求文档中定义的数据模型、指标计算、事件记录、通知编排、微干预工具以及导出功能。

## 快速开始

```bash
swift test
```

以上命令会执行 `QuitBuddyKitTests`，验证关键计算（无烟天数、节省金额、高风险时间段、CSV 导出等）与控制器流程（Onboarding → 记录 → 通知调度）。

## 模块概览

| 路径 | 说明 |
| --- | --- |
| `Sources/QuitBuddyKit/Models` | QuitPlan、CravingEvent、Snapshot、成就、主题等数据模型 |
| `Sources/QuitBuddyKit/Services` | 指标计算、日志持久化、成就引擎、通知调度、CSV 导出、共享快照、控制器等核心服务 |
| `Sources/QuitBuddyKit/Interventions` | 呼吸练习、延迟计时器与替代行为文案库 |
| `Sources/QuitBuddyKit/Utilities` | 公用工具（如统一日历配置、JSON 文件存储） |
| `Tests/QuitBuddyKitTests` | 针对主要业务流程的单元测试 |

## 产品需求文档

* 戒烟 App（QuitBuddy）V1.0 需求文档：[`docs/quitbuddy_v1_requirements.md`](docs/quitbuddy_v1_requirements.md)

