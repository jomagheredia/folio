require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Capybara's fill_in can set the DOM value without React onChange, so the next
  # render (or a following fill_in) restores "". Dispatch input the way a typed
  # value would, after Inertia has mounted the page.
  def fill_in_react(locator, with:)
    field = find_field(locator)
    field.execute_script(<<~JS, with)
      const el = this;
      const value = arguments[0];
      const proto = el.tagName === "TEXTAREA"
        ? window.HTMLTextAreaElement.prototype
        : window.HTMLInputElement.prototype;
      Object.getOwnPropertyDescriptor(proto, "value").set.call(el, value);
      el.dispatchEvent(new InputEvent("input", { bubbles: true, inputType: "insertFromPaste", data: value }));
      el.dispatchEvent(new Event("change", { bubbles: true }));
    JS
    assert_field locator, with: with
  end
end
