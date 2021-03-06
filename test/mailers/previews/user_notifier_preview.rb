# Preview all emails at http://localhost:3000/rails/mailers/user_notifier
class UserNotifierPreview < ActionMailer::Preview

  def verification_email_preview
    UserNotifier.verification_email(User.first)
  end

  def forgot_password_email_preview
    UserNotifier.forgot_password_email(User.first)
  end

  def order_placed_email_preview
    UserNotifier.order_placed_email(User.first, Order.first)
  end

end
