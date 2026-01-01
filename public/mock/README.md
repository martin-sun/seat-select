
# 座位数据格式说明

## 文件

- `seats.json` - 新格式（春晚座位系统）
- ~~`seatLove.json`~~ - 已删除

---

## 数据结构

```json
{
  "event_id": "evt-spring-gala-2026",
  "zone_prices": {
    "red": 100,
    "pink": 80,
    "purple": 60
  },
  "seats": [...],
  "zone_config": [...]
}
```

---

## 座位字段 (seats)

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 座位唯一标识 |
| `row` | string | 排号（显示用） |
| `col` | string | 列号（显示用） |
| `gRow` | number | 网格行坐标（渲染用） |
| `gCol` | number | 网格列坐标（渲染用） |
| `zone` | string | 分区：`red` / `pink` / `purple` |
| `status` | string | 状态：`available` / `locked` / `sold` |
| `locked_until` | string\|null | 锁定过期时间 (ISO 8601) |

---

## 座位状态 (status)

| 状态 | 说明 | 存储位置 |
|------|------|----------|
| `available` | 可选 | 后端 |
| `selected` | 已选（当前用户） | 仅前端 |
| `locked` | 临时锁定（24小时） | 后端 |
| `sold` | 已售 | 后端 |

---

## 分区规则

按列划分（中间最贵）：

| 分区 | 列范围 | 价格 |
|------|--------|------|
| 红区 (red) | col 6-10 | $100 |
| 粉区 (pink) | col 3-5, 11-13 | $80 |
| 紫区 (purple) | col 1-2, 14-15 | $60 |

---

## zone_config 配置

每个分区包含：

```json
{
  "zone": "red",
  "name": "红区",
  "price": 100,
  "color": "#DC2626",
  "icons": {
    "available": "url...",
    "selected": "url...",
    "locked": "url...",
    "sold": "url..."
  }
}
```

---

## 统计

- 总座位数：119
- 红区：45 座
- 粉区：54 座
- 紫区：20 座
