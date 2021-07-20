#include <functional>
#include <string>
#include <thread>

// Formatted with Google style.
// From https://cpppatterns.com/patterns/create-thread.html.

void do_something();
void func(std::string str, int &x);

int main() {
  std::string str = "Test";
  int x = 5;
  std::thread t{func, str, std::ref(x)};
  do_something();
  t.join();
}
