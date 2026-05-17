# 结构化标签推荐改造说明（基于商品名称知识打标）

## 1. 现状扫描结论

- 商品总量：`190`
- `keywords` 非空覆盖：`190/190`
- 但 `keywords` 的场景词覆盖接近 `0`（几乎无“沙拉/榨汁/火锅/便当”等标准场景词）
- `category` 结构完整，可稳定支撑角色与部分场景推断
- 当前 `PlanServiceImpl` 关键词匹配点集中在：
  - 忌口过滤（`containsDislike`）
  - 饮食目标打分（`scoreMealGoods`）
  - 角色 fallback（`fallbackRoleMatchByText`）
  - 场景打分与匹配度（`scoreComboGoods`/`scoreComboFit`）

结论：推荐主逻辑需要迁移到 `tag/goods_tag`，关键词仅保留兜底。

## 2. 自动可提取标签维度（名称知识 + 分类结构）

- `role`：主菜/配菜/水果/基础食材/蔬菜配料（高覆盖，分类驱动）
- `scene`：一人食/蔬果搭配/沙拉/榨汁/火锅/便当配菜（分类映射）
- `diet`：轻负担/高纤/均衡（分类映射）
- `exclude`：高糖/生冷（名称规则，保守推断）
- `cook`：免烹饪/快手烹饪（水果/蔬菜分类映射）
- `portion`：小份/标准份（基于单位和名称弱规则；后续建议 SKU 级）
- `nutrition`：维C友好/纤维友好/饱腹友好（分类映射）
- `selling`：推荐/热销（业务字段映射）
- `storage`：冷藏（从关键词兜底）

## 3. SQL 脚本

脚本：`docs/sql/2026-05-17-structured-tag-bootstrap.sql`

能力：
- 升级 `tag` 表为结构化标签字典（兼容旧数据）
- 保留旧营销标签，新增结构化标签
- 批量自动打标（`goods_tag`）
- 提供人工复核查询

## 4. 推荐逻辑替换映射（方法级）

1. `containsDislike`  
- 现状：关键词判断  
- 改造：根据商品 `exclude` 标签与用户忌口标签冲突过滤

2. `scoreMealGoods` 的 `dietGoal` 文本匹配  
- 现状：`text.matches(...)`  
- 改造：命中 `diet` 标签加分（`diet_high_fiber`/`diet_light`/`diet_balanced`）

3. `fallbackRoleMatchByText`  
- 现状：关键词 fallback  
- 改造：优先 `role` 标签，分类兜底，最后才文本兜底

4. `scoreComboGoods` 的 `goalScene` 文本匹配  
- 现状：场景关键词加分  
- 改造：命中 `scene` 标签加分

5. `scoreComboFit`  
- 现状：名称关键词命中 +8  
- 改造：改成“目标标签命中率分”：
  - 角色命中
  - 场景命中
  - 饮食标签命中

## 5. 改造计划（优先级/风险/工作量）

1. P0：执行标签引导 SQL（本次已提供）  
- 风险：低  
- 工作量：小

2. P0：`PlanServiceImpl` 第一批替换（过滤/打分改为标签）  
- 风险：中（推荐行为变化）  
- 工作量：中

3. P1：补 `sku_tag`（份量与场景细粒度迁移到 SKU）  
- 风险：中  
- 工作量：中

4. P1：管理端加“标签校正”界面  
- 风险：中  
- 工作量：中

5. P2：埋点闭环 + 权重调优  
- 风险：中  
- 工作量：中-大

## 6. 风险提示

- 名称知识打标属于“高可用启动方案”，不是最终真理。
- 推荐精度仍依赖后续人工校正与 SKU 级标签完善。
- 现有 `keywords` 模板化较强，不建议继续作为主推荐依据。
