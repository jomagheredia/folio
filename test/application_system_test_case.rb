require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Capybara's native fill/click often miss React 19 + Inertia useForm handlers
  # (controlled inputs, type="button", overlapping headings). Drive those
  # through the native value setter + a bubbling input/click instead.
  def js_click(selector)
    find(selector)
    page.execute_script("document.querySelector(#{selector.to_json}).click()")
  end

  def fill_react_field(id, value)
    page.execute_script(<<~JS)
      const el = document.getElementById(#{id.to_json})
      if (!el) throw new Error("No element with id " + #{id.to_json})
      const proto = el instanceof HTMLTextAreaElement
        ? window.HTMLTextAreaElement.prototype
        : window.HTMLInputElement.prototype
      const setter = Object.getOwnPropertyDescriptor(proto, "value").set
      setter.call(el, #{value.to_json})
      el.dispatchEvent(new Event("input", { bubbles: true }))
    JS
  end
end
