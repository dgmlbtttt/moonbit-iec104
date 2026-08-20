# IEC 104 验收增强设计

## 目标

把现有纯 MoonBit IEC 60870-5-104 协议库提升为可复用、可验证的验收版本：补齐真实 TCP 分片下的 APDU 流式处理、关键 ASDU 边界与时间标签、主站/子站事件闭环和确定性场景基准，同时让仓库具备可复现的 CI、文档和发布流程。

## 范围与非目标

范围包括协议栈核心、子站事件处理、轻量场景驱动、边界测试、基准命令、README、CI、MoonBit 元数据和发布 workflow。保持现有公共 API 兼容，新增 API 采用独立类型和方法。

不实现真实 TCP socket、生产级 SCADA 网络服务或未在申报书/现有架构中承诺的协议扩展；基准只报告本机当前运行的实测数据，不预填固定性能数字。

## 设计

### 协议输入层

在 `src/apdu` 增加带容量上限的 `APDUStreamDecoder`。它接收任意大小的字节片段，识别 `0x68` 起始符和 APCI 长度，缓存半帧，连续提取完整 APDU，并对无效起始符、零长度、超过 `MAX_APDU_LEN`、截断和解码失败给出稳定错误。所有缓存操作保持确定性且不会无限增长。

### ASDU 与时间标签

在 `src/types` 增加可验证的 CP24/CP56 编解码辅助和范围检查；在 `src/asdu` 增加时间标签信息体、位串/调节步/带限定词命令等实际 IEC 104 信息对象，并复用已有 `InformationElement`、`ASDUHeader` 和 `ByteBuffer`。非法地址、对象数、限定词和时间字段必须返回错误而不是静默截断。

### 主站/子站闭环与场景

在 `src/slave` 增加有容量的事件队列和点库快照，在 `src/master` 增加总召唤分批消费与确认状态，在 `src/simulation` 增加确定性场景步骤/事件记录。场景只编排已有仿真模型和协议对象，避免复制业务逻辑。

### 测试与基准

新增测试先行覆盖：分片/粘包/噪声前缀、长度边界、序号回绕、时间边界、ASDU 往返、非法输入、事件队列容量、总召唤批次和场景故障恢复。CLI 输出当前工具链版本、样本数、耗时和吞吐；不把运行结果写死在源码中。

### 工程化

README 只描述项目、安装、架构、API、示例、测试、基准、发布和许可证，不出现申报/结项/赛事或贡献者内部表述。`.github/workflows/ci.yml` 对照 MoonBit 社区模板执行三平台 `moon update`、`moon check --target all`、`moon test --target all`、格式和接口差异检查；另提供手动 Mooncakes 发布 workflow。`PROPOSAL.md` 不修改。

## 验收标准

1. `moon check --target all`、`moon test --target all`、`moon fmt --check` 和 `moon info` 在本地通过。
2. 新增功能均有可重复测试，边界和错误路径覆盖核心协议入口。
3. `.mbt` 实际行数由命令统计，README 与基准结果不虚报。
4. README 可从干净环境指导构建、测试、运行和基准。
5. GitHub 默认分支上的 CI 与发布 workflow 可读、最小权限、无凭据硬编码。
