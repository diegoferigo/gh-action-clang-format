#include <memory>

// Formatted with Mozilla style.
// From https://cpppatterns.com/patterns/pimpl.html

class foo
{
public:
  foo();
  ~foo();
  foo(foo&&);
  foo& operator=(foo&&);

private:
  class impl;
  std::unique_ptr<impl> pimpl;
};
