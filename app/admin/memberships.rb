ActiveAdmin.register Membership do
  permit_params :member_id, :membership_tier_id, :status, :started_at, :expires_at, :transaction_id

  scope :all, default: true
  scope :active, -> { where(status: 'active') }
  scope :expired, -> { where('expires_at < ?', Time.now) }

  filter :member_id, label: "Member ID"
  filter :membership_tier
  filter :status, as: :select, collection: -> { Membership.statuses }
  filter :expires_at

  index do
    selectable_column
    id_column
    column :member
    column :membership_tier
    column :status do |m|
      status_tag m.status
    end
    column :expires_at
    actions
  end

  form do |f|
    f.semantic_errors
    f.inputs "Membership Details" do
      f.input :member, collection: Member.all.map { |m| [m.user&.username || m.id, m.id] }
      f.input :membership_tier
      f.input :status
      f.input :started_at, as: :datepicker
      f.input :expires_at, as: :datepicker
      f.input :transaction_id
    end
    f.actions
  end

  member_action :renew, method: :put do
    resource.update(
      status: 'active',
      started_at: Time.current,
      expires_at: 1.month.from_now
    )
    redirect_to admin_membership_path(resource), notice: "Membership renewed for 1 year!"
  end

  action_item :renew_button, only: :show do
    if membership.status != 'active'
      link_to "Renew for 1 Month", renew_admin_membership_path(membership), method: :put, data: { confirm: "Are you sure you want to renew this membership?" }
    end
  end
end