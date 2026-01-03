
# 座位数据格式说明

## 数据存储

当前使用 **Supabase** 后端存储座位和事件数据。座位数据通过实时订阅同步。

---

## 数据结构 (Supabase)

### events 表

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | UUID | 事件唯一标识 |
| `name` | string | 事件名称 |
| `hall_name` | string | 场馆名称 |
| `show_time` | timestamptz | 演出时间 |
| `zone_prices` | jsonb | 各分区价格 |
| `zone_config` | jsonb | 分区配置 |
| `max_seats_per_booking` | int | 每单最大座位数 |

### seats 表

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 座位唯一标识 |
| `event_id` | UUID | 所属事件 |
| `row` | string | 排号（显示用，如 'A', 'B'） |
| `col` | string | 列号（显示用） |
| `g_row` | number | 网格行坐标（渲染用） |
| `g_col` | number | 网格列坐标（渲染用） |
| `zone` | string | 分区：`red` / `pink` / `purple` / `green` / `handicaped` |
| `status` | string | 状态：`available` / `reserved` / `sold` / `unavailable` |
| `locked_until` | timestamptz\|null | 锁定过期时间 |
| `reservation_id` | UUID\|null | 关联预订 |

---

## 座位状态 (status)

| 状态 | 说明 |
|------|------|
| `available` | 可选 |
| `reserved` | 已预订 |
| `sold` | 已售 |
| `unavailable` | 不可选（如工作人员预留座位） |

> 前端额外维护 `selected` 状态（仅前端，不存储）

---

## 分区配置

当前共有 **5 个分区**：

| 分区 | 英文名 | 颜色 | 价格 | 说明 |
|------|--------|------|------|------|
| 红区 | red | #DC2626 | $20 | 中心区域，价格最高 |
| 粉区 | pink | #EC4899 | $15 | 中间区域 |
| 紫区 | purple | #7C3AED | $10 | 外围区域 |
| 绿区 | green | #22C55E | - | 演职工作人员区，不对外售票 |
| 无障碍区 | handicaped | #F59E0B | $20 | 无障碍座位（宽度 2） |

### zone_config 结构

```json
{
  "zone": "red",
  "name": "Red Zone",
  "color": "#DC2626",
  "icons": {
    "available": "/icons/seats/seat-red-available.svg",
    "selected": "/icons/seats/seat-red-selected.svg",
    "locked": "/icons/seats/seat-red-locked.svg",
    "sold": "/icons/seats/seat-red-sold.svg"
  }
}
```

无障碍区特殊配置：
```json
{
  "zone": "handicaped",
  "name": "Handicapped",
  "color": "#F59E0B",
  "icons": {
    "locked": "/icons/seats/seat-handicaped-locked.svg"
  },
  "width": 2  // 座位宽度为普通座位的 2 倍
}
```

---

## 排号说明

- 排号范围：A-Q（共 17 排）
- A 排最靠近舞台，Q 排最远
- K、L 排在中间区域存在断开
- gRow 坐标：A=1, B=2, ..., Q=17

---

## 图标文件路径

各分区状态图标位于 `public/icons/seats/`：
- `seat-{zone}-{status}.svg`

例如：`seat-red-available.svg`, `seat-green-sold.svg`

---

# 春晚首页设计架构

## 技术栈

- **框架**: Vue 3 + Vue Router
- **国际化**: vue-i18n (中文/英文)
- **样式**: Tailwind CSS
- **后端**: Directus (内容管理) + Supabase (座位数据)

## 页面结构

### 路由配置

| 路由 | 组件 | 说明 |
|------|------|------|
| `/:lang` | ChunwanHome | 首页 |
| `/:lang/tickets` | HallSeat | 选座页面 |
| `/:lang/programs` | ChunwanPrograms | 节目单 |
| `/:lang/reservation/:id` | ReservationStatus | 预订状态 |
| `/:lang/my-orders` | MyOrders | 我的订单 |

### 首页组件架构

```
ChunwanHome.vue (主容器)
├── Navigation (导航栏)
├── HeroBanner (横幅)
├── EventInfo (活动信息)
├── TicketCard x3 (票价卡片)
├── HistoryCard x3 (往期回顾)
└── Footer (页脚)
```

## 首页组件说明

### HeroBanner (横幅)

**位置**: `src/pages/home/components/HeroBanner.vue`

**功能**:
- 显示活动年份、主标题、副标题
- 中国春节主题装饰（灯笼、生肖图案）
- CTA 购票按钮

**设计元素**:
- 渐变红色背景
- 浮动灯笼动画 (animate-bounce)
- 年份标签徽章
- 装饰分隔线

### EventInfo (活动信息)

**位置**: `src/pages/home/components/EventInfo.vue`

**功能**:
- 显示活动日期、时间、地点
- 活动介绍文本

**设计元素**:
- 半透明玻璃卡片 (backdrop-blur)
- 图标 + 文字布局
- 本地化日期格式

### TicketCard (票价卡片)

**位置**: `src/pages/home/components/TicketCard.vue`

**功能**:
- 展示各分区票价信息
- VIP 角标标识
- 可选/售罄状态

**票种配色**:
| 票种 | 颜色标识 | 渐变样式 |
|------|----------|----------|
| 金票 | gold | from-yellow-600 via-yellow-500 to-yellow-700 |
| 银票 | silver | from-gray-600 via-gray-500 to-gray-700 |
| 铜票 | bronze | from-amber-700 via-amber-600 to-amber-800 |

### HistoryCard (往期回顾)

**位置**: `src/pages/home/components/HistoryCard.vue`

**功能**:
- 展示往届春晚视频缩略图
- 年份标签
- 悬停播放按钮效果

## 设计风格

### 色彩方案

```css
/* 主色调 */
--primary-red: #991B1B (red-900)     /* 深红背景 */
--accent-red: #B91C1C (red-800)      /* 中红 */
--gold: #EAB308 (yellow-500)         /* 金色文字/按钮 */
--gold-light: #FACC15 (yellow-400)   /* 浅金 */
```

### 响应式断点

| 断点 | 宽度 | 用途 |
|------|------|------|
| sm | 640px | 手机横屏 |
| md | 768px | 平板 |
| lg | 1024px | 桌面 |

### 移动端优化

- 固定底部购票按钮 (仅移动端显示)
- 网格布局自适应 (1列 → 2列 → 3列)
- 导航栏汉堡菜单（待实现）

## 国际化 (i18n)

### 支持语言

- `zh-CN` - 简体中文
- `en-US` - English

### 翻译命名空间

`chunwan.*` - 首页相关翻译
```js
// 示例
$t('chunwan.nav.title')        // 导航标题
$t('chunwan.banner.yearLabel') // 年份标签
$t('chunwan.ticketCard.select')// 选择按钮
```

## 数据来源

### Directus CMS

| 数据类型 | API 函数 | 用途 |
|----------|----------|------|
| Settings | `getSettings()` | 站点配置、标题、日期 |
| Tickets | `getTickets()` | 票价信息 |
| History | `getHistory()` | 往期回顾 |

### 数据流

```
Directus API → Directus SDK → Component Props → Template
```

## 文件结构

```
src/pages/home/
├── ChunwanHome.vue           # 首页主容器
├── ChunwanPrograms.vue       # 节目单页面
└── components/
    ├── HeroBanner.vue        # 横幅组件
    ├── EventInfo.vue         # 活动信息
    ├── TicketCard.vue        # 票价卡片
    └── HistoryCard.vue       # 往期回顾卡片
```
