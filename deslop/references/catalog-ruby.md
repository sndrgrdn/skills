# Catalog of Slop — Ruby and Rails

Load when diff touch `.rb`, `.rake`, `.erb`, `Gemfile`, or Rails-shaped folder (`app/`, `config/`, `db/`).

## Ruby

- `attr_reader :foo` when ivar only read inside class
- `private :method_name` on line after `def method_name` (already private via section)
- module hierarchy for ten-line class
- service object + policy class + concern wrapping a 3-line helper — AI asked "add feature", generated three abstractions where a model method suffices
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
- `after_save` / `after_create` callback doing email, API call, or multi-step workflow — move to service object or background job
- `.save` (without `!`) in service objects or jobs — silent failure, no error raised. use `.save!` or check return value
- `.where.order.joins` chain in controller action — extract to model scope
- `.all.select { }` / `.all.map { }` / `.all.reject { }` — loads entire table into Ruby. filter in SQL with `.where`, sort with `.order`

## Rails test (RSpec / Minitest)

- `FactoryBot.create` when `build_stubbed` enough
- `let!` that nobody reference (eager, no reader)
- `before { ... }` creating record irrelevant to `it` block
- `describe "#method"` with one `it` that duplicate method name in string
- tautological association test — `it { should have_many(:students) }` restates schema, tests no behavior. test what the association enables instead
- tautological column test — `it { should have_db_column(:email) }` — migration already proves this
- stubbing the object under test — `allow(subject).to receive(:method)` — tests a phantom object, not real code. stub collaborators, not the subject
- `allow_any_instance_of(Klass)` — ambiguous semantics, brittle, design smell per rspec-mocks docs. use `instance_double` + dependency injection
- nested contexts deeper than 3 levels — `describe > context > context > context > it` makes setup opaque. if you need more nesting, the class under test is too complex
- weak / existence-only assertions — `expect(result).to be_truthy` / `be_present` / `not_to be_nil` without checking actual value. test specific business outcomes: exact values, side effects, failure paths
- premature `shared_examples` — extracting shared examples for 2 occurrences, global naming, setup defined far from assertion. prefer duplication over premature DRY in specs
- silent `skip` / `pending` added without comment — AI can't fix a failing test so it skips it. `skip` and `pending` must have a reason and issue link

## Neighbor check examples (Ruby)

- file uses `.freeze` on 5 constants already → new `.freeze` is **local idiom**, keep
- file never uses `.try` → new `.try(:foo)` is **novel**, flag
- module uses `present?` everywhere, never `presence` → new `present? && present?` is ambiguous; look at whole folder before deciding
- spec file uses `allow_any_instance_of` in 10 existing tests → **local idiom**, keep (but note for later cleanup)
- spec file has zero shared_examples → new `it_behaves_like` for 2 cases is **novel**, flag
- controller already has `.where` chains (established pattern) → new `.where` chain is **ambiguous**; check if model scopes exist elsewhere
