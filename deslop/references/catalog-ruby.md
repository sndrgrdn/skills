# Catalog of Slop — Ruby and Rails

Load when diff touch `.rb`, `.rake`, `.erb`, `Gemfile`, or Rails-shaped folder (`app/`, `config/`, `db/`).

## Ruby

- `attr_reader :foo` when ivar only read inside class
- `private :method_name` on line after `def method_name` (already private via section)
- module hierarchy for ten-line class
- `ApplicationSomething` inherit when child add nothing
- `self.` prefix inside instance method, not disambiguation
- `return` at end of method (implicit return is idiom)
- `Hash.new { |h, k| h[k] = [] }` when caller always write known keys
- `Struct.new(...)` used once, never reused — inline hash or plain class enough

## Rails

- `find_by(id: x)` + manual `raise` when `find(x)` raise same way
- `.present? && other.present?` when `.presence && other.presence` or safe-nav work
- `.try(:foo)` when `&.foo` work
- `.all` at end of query chain (`User.where(...).all`) — redundant
- `after_initialize` doing work that belong in factory / builder
- `belongs_to :thing, optional: true` on column with DB NOT NULL constraint
- `validates :x, presence: true` when DB NOT NULL + callback already set
- scope `scope :active, -> { where(active: true) }` used one place — inline
- `includes(...)` for association test never touch (over-eager load)
- `touch: true` on association nobody observe
- `before_save` callback doing trivial assignment — move to setter or writer

## Rails test (RSpec / Minitest)

- `FactoryBot.create` when `build_stubbed` enough
- `let!` that nobody reference (eager, no reader)
- `before { ... }` creating record irrelevant to `it` block
- `describe "#method"` with one `it` that duplicate method name in string

## Neighbor check examples (Ruby)

- file uses `.freeze` on 5 constants already → new `.freeze` is **local idiom**, keep
- file never uses `.try` → new `.try(:foo)` is **novel**, flag
- module uses `present?` everywhere, never `presence` → new `present? && present?` is ambiguous; look at whole folder before deciding
