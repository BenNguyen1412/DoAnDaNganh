const form = document.getElementById('auth-form');
const email_input = document.getElementById('email-input');
const password_input = document.getElementById('password-input');
const confirm_password_input = document.getElementById('confirm-password-input');
const error_message = document.getElementById('error-message');

form.addEventListener('submit', (e) => {
  let errors = []

  if (confirm_password_input) {
    errors = getSignupErrors(email_input.value, password_input.value, confirm_password_input.value)
  }
  else {
    errors = getLoginErrors(email_input.value, password_input.value)
  }

  if (errors.length > 0) {
    e.preventDefault()
    error_message.innerText = errors.join(". ")
  }
})

function getSignupErrors(email, password, confirm_password) {
  let errors = []

  if (email === '' || email == null) {
    errors.push('Yêu cầu nhập email')
    email_input.parentElement.classList.add('incorrect-form')
  }

  if (password === '' || password == null) {
    errors.push('Yêu cầu nhập mật khẩu')
    password_input.parentElement.classList.add('incorrect-form')
  }

  if (password.length < 8) {
    errors.push('Mật khẩu phải có ít nhất 8 ký tự')
    password_input.parentElement.classList.add('incorrect-form')
  }

  if (password != confirm_password) {
    errors.push('Mật khẩu không trùng khớp')
    password_input.parentElement.classList.add('incorrect-form')
    confirm_password_input.parentElement.classList.add('incorrect-form')
  }

  return errors;
}

function getLoginErrors(email, password) {
  errors = []

  if (email === '' || email == null) {
    errors.push('Yêu cầu nhập email')
    email_input.parentElement.classList.add('incorrect-form')
  }

  if (password === '' || password == null) {
    errors.push('Yêu cầu nhập mật khẩu')
    password_input.parentElement.classList.add('incorrect-form')
  }

  return errors
}

const allInputs = [email_input, password_input, confirm_password_input].filter(input => input != null)

allInputs.forEach(input => {
  input.addEventListener('input', () => {
    if (input.parentElement.classList.contains('incorrect-form')) {
      input.parentElement.classList.remove('incorrect-form')
      error_message.innerText = ''
    }
  });
});
