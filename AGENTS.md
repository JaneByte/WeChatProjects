# 项目开发规范

## 数据库规范
- 数据库表名与字段名统一使用 `snake_case`；Java 实体/DTO/VO 统一使用 `camelCase`
- 新增业务表默认使用 `InnoDB` 引擎，禁止新建 `MyISAM` 表
- 所有跨表关系必须声明外键或等价约束策略（至少在设计文档中明确）
- 涉及保留字（如 `order`、`user`）时，SQL 中必须使用反引号包裹；新表命名尽量规避保留字

## 后端规范
- 所有后端查询必须通过 Mapper 层，禁止在 Controller/Service 中拼接原生 SQL 字符串
- MyBatis 参数必须使用 `#{}` 占位，禁止使用 `${}` 直接拼接用户输入
- API 返回统一使用 `ApiResponse<T>`（包含 `code`/`message`/`data`/`timestamp`），禁止返回 `Map` 或裸 `String`
- 必须启用 `@RestControllerAdvice` 全局异常处理，Controller 层不分散写 `try-catch`

## 前端规范
- 所有网络请求统一走 `utils/request.js`，页面中禁止直接使用 `wx.request` 或 `fetch`
- API 地址仅允许从 `config` 文件读取，禁止在页面中硬编码 `baseUrl` 或第三方接口地址
- 页面创建流程固定：创建四件套（`.js` / `.wxml` / `.scss` / `.json`）→ 注册路由 → 接入 `request` 层 → 补齐异常态/空态
- 样式默认使用 `rpx`；仅在 `media query` / 滤镜等必要场景可使用 `px`，且需注释说明；禁止使用 `!important`

## 通用规范
- **编码要求**：所有生成的代码文件（`.js`/`.json`/`.wxml`/`.wxss`/`.scss`）必须使用 **UTF-8 无 BOM** 编码，禁止使用 GBK/GB2312 等编码。