# Branch Coverage Guide

## What is Branch Coverage?

**Branch coverage** (also called decision coverage or path coverage) measures whether your tests execute **both the TRUE and FALSE paths** of every conditional statement in your code.

### Line Coverage vs Branch Coverage

**Line Coverage**: Tests if a line of code is executed at least once.
```ruby
def check_age(age)
  if age > 18        # Line 2
    puts "Adult"     # Line 3
  end
end

check_age(25)  # Only tests the TRUE branch of the if
# Line Coverage: 100% (all lines executed)
# Branch Coverage: 50% (only TRUE branch tested, FALSE branch never executed)
```

**Branch Coverage**: Tests if both the TRUE and FALSE outcomes of conditionals are executed.

---

## Why Branch Coverage Matters

1. **Catches Logic Errors**: You might have a bug that only manifests in one branch
2. **Prevents False Sense of Security**: 100% line coverage doesn't mean 100% branch coverage
3. **Finds Edge Cases**: Forces you to test both positive and negative scenarios

### Real-World Example:

```ruby
def process_user(user)
  if user.admin? && user.active?  # Line 2 - compound condition
    grant_permissions(user)        # Line 3
  else
    deny_permissions(user)         # Line 5
  end
end

# Scenario 1: admin=true, active=true
process_user(admin_active_user)
# Scenario 2: admin=false, active=true
process_user(non_admin_active_user)
# Scenario 3: admin=true, active=false
process_user(admin_inactive_user)
# Scenario 4: admin=false, active=false (NEVER TESTED!)
```

---

## Types of Conditions and Their Branches

### 1. **Simple If Statement** (2 branches)
```ruby
if user.deleted?
  return :deleted_account
end
```
**TRUE branch**: User is deleted → return :deleted_account
**FALSE branch**: User is not deleted → continue execution

**Tests needed**:
```ruby
it "returns error when user is deleted" do
  user.update(deleted_at: 1.year.ago)
  # Tests TRUE branch
end

it "does not return error when user is active" do
  # user has no deleted_at
  # Tests FALSE branch
end
```

---

### 2. **If-Else Statement** (2 branches)
```ruby
if recoverable
  send_reset_instructions
else
  add_error(:email, :not_found)
end
```
**TRUE branch**: recoverable exists → send instructions
**FALSE branch**: recoverable is nil → add error

**Tests needed**:
```ruby
it "sends reset instructions when user found (TRUE)" do
  result = User.send_reset_password_instructions(email: existing_user_email)
  expect(result.reset_password_token).to be_present
end

it "adds error when user not found (FALSE)" do
  result = User.send_reset_password_instructions(email: non_existent_email)
  expect(result.errors[:email]).to be_present
end
```

---

### 3. **AND (&&) Operator** (3+ branches)
```ruby
if recoverable.deleted? && recoverable.deleted_at < 1.year.ago
  add_error(:base, :deleted_account_expired)
end
```

**Branches**:
1. **Both TRUE**: deleted=true AND deleted_at < 1.year.ago → add error
2. **First FALSE**: deleted=false AND any value → skip block
3. **First TRUE, Second FALSE**: deleted=true AND deleted_at >= 1.year.ago → skip block

**Tests needed**:
```ruby
# Branch 1: Both conditions TRUE
it "returns error when user is permanently deleted" do
  user.update(deleted_at: 18.months.ago)
  result = User.send_reset_password_instructions(email: user.email)
  expect(result.errors[:base]).not_to be_empty
end

# Branch 2: First condition FALSE (not deleted)
it "sends instructions when user is active" do
  # user not deleted
  expect {
    User.send_reset_password_instructions(email: user.email)
  }.to change { user.reload.reset_password_token }
end

# Branch 3: First TRUE, Second FALSE (recently deleted, within 1 year)
it "sends instructions when user recently deleted" do
  user.update(deleted_at: 1.week.ago)
  expect {
    User.send_reset_password_instructions(email: user.email)
  }.to change { user.reload.reset_password_token }
end
```

---

### 4. **OR (||) Operator** (3+ branches)
```ruby
if self.actable_type.nil? || self.actable_type == 'Member'
  create_member_identity
end
```

**Branches**:
1. **First TRUE**: actable_type is nil → create identity (short-circuits, second not evaluated)
2. **First FALSE, Second TRUE**: actable_type is not nil BUT equals 'Member' → create identity
3. **Both FALSE**: actable_type is 'Moderator' or other → skip block

**Tests needed**:
```ruby
# Branch 1: First condition TRUE
it "creates identity when actable_type is nil" do
  user = build(:user, actable_type: nil)
  user.build_member_identity
  expect(user.actable).to be_a(Member)
end

# Branch 2: First FALSE, Second TRUE
it "creates identity when actable_type is Member" do
  user = build(:user, actable_type: 'Member')
  user.build_member_identity
  expect(user.actable).to be_a(Member)
end

# Branch 3: Both FALSE
it "does not create when actable_type is Moderator" do
  user = build(:user, actable_type: 'Moderator')
  original = user.actable
  user.build_member_identity
  expect(user.actable).to eq(original)  # Unchanged
end
```

---

### 5. **Ternary Operator** (2 branches)
```ruby
def inactive_message
  deleted? ? :deleted_account_expired : super
end
```

**TRUE branch**: deleted? returns true → return :deleted_account_expired
**FALSE branch**: deleted? returns false → return super

**Tests needed**:
```ruby
# TRUE branch
it "returns deleted_account_expired when user is deleted" do
  user.update(deleted_at: 2.years.ago)
  expect(user.inactive_message).to eq(:deleted_account_expired)
end

# FALSE branch
it "returns super when user is not deleted" do
  result = user.inactive_message
  expect(result).not_to eq(:deleted_account_expired)
end
```

---

### 6. **Safe Navigation (&.)** and **Nil-Coalescing (||)**
```ruby
user&.valid_password?(password) ? user : nil
```

**Branches**:
- **user is not nil**: execute valid_password? → return user or nil based on password
- **user is nil**: &. short-circuits → return nil

**Tests needed**:
```ruby
# TRUE: user found and password valid
it "returns user when credentials valid" do
  result = User.authenticate("test@example.com", "correct_password")
  expect(result).to be_a(User)
end

# FALSE: user found but password invalid
it "returns nil when password incorrect" do
  result = User.authenticate("test@example.com", "wrong_password")
  expect(result).to be_nil
end

# FALSE: user not found (nil)
it "returns nil when user not found" do
  result = User.authenticate("nonexistent@example.com", "any_password")
  expect(result).to be_nil
end
```

---

## Checking Branch Coverage in Your Project

### Using SimpleCov with Branch Coverage

Your project uses SimpleCov. It shows both line and branch coverage:

```
Line Coverage: 18.72% (414 / 2212)
Branch Coverage: 27.05% (33 / 122)
```

- **Line Coverage**: 414 lines out of 2,212 are executed
- **Branch Coverage**: 33 branches out of 122 possible branches are tested

### Viewing Coverage Reports

```bash
bundle exec rspec spec/models/user_spec.rb
# Then check coverage/index.html in your browser
```

Look for:
- 🟢 Green: Fully covered (both branches tested)
- 🟡 Yellow: Partially covered (only one branch tested)
- 🔴 Red: Not covered (no branches tested)

---

## Branch Coverage in the User Model

### Line 34 - `build_member_identity`
```ruby
def build_member_identity
  self.actable ||= Member.new if self.actable_type.nil? || self.actable_type == 'Member'
end
```

**3 Test Cases**:
1. ✅ `actable_type.nil?` is TRUE → creates Member
2. ✅ `actable_type == 'Member'` is TRUE → creates Member
3. ✅ Both FALSE (e.g., 'Moderator') → does not create

---

### Line 93 - `send_reset_password_instructions`
```ruby
if recoverable.deleted? && recoverable.deleted_at < 1.year.ago
  recoverable.errors.add(:base, :deleted_account_expired)
  return recoverable
end
```

**3+ Test Cases for AND condition**:
1. ✅ Both TRUE (deleted AND old) → adds error
2. ✅ First FALSE (not deleted) → skips block
3. ✅ First TRUE, Second FALSE (deleted but recent) → skips block

---

## Best Practices for Branch Coverage

1. **Write Tests for Both Outcomes**: Don't just test the "happy path"
2. **Use Descriptive Test Names**: Include which branch you're testing
3. **Document Edge Cases**: Comment what condition makes each branch execute
4. **Aim for 80%+ Branch Coverage**: 100% isn't always needed but 80%+ is a good goal
5. **Test Compound Conditions Thoroughly**: AND/OR operators need special attention

---

## Exercise: Identifying Uncovered Branches

Look at this code:
```ruby
def process_order(order)
  if order.valid? && order.ready_to_ship?
    if order.priority?
      ship_with_priority(order)
    else
      ship_normal(order)
    end
  else
    mark_as_invalid(order)
  end
end
```

**How many branches?**
- Outer if: 2 (valid && ready) / (invalid or not ready)
- Inner if: 2 (priority) / (not priority)
- **Total: 4 branches** (at minimum 4 tests needed)

**Required Tests**:
1. Valid & Ready & Priority
2. Valid & Ready & Not Priority
3. Invalid or Not Ready (catches both FALSE cases)
4. (Optional) More specific: Valid but Not Ready, Valid & Ready but Not Priority, etc.

---

## Summary

| Concept | Coverage | What It Tests |
|---------|----------|---------------|
| **Line Coverage** | Does the line execute? | 100% doesn't guarantee correctness |
| **Branch Coverage** | Do all if/else paths execute? | Finds logic bugs and edge cases |
| **Both TRUE** | AND: first AND second both true | Primary path |
| **Both FALSE** | AND/OR: at least one false | Error handling |
| **Partial TRUE/FALSE** | Mixed conditions | Edge cases |

**Remember**: High branch coverage = more confident tests! 🚀

