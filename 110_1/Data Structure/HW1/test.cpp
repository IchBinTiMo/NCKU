#include <iostream>
#include <string>
#include <fstream>
#include <stack>

using namespace std;

typedef struct Node
{
  int x, y;
  struct Node *next;
} node;

node *make_a_node(int x, int y)
{
  node *n = new node();
  n->x = x;
  n->y = y;
  n->next = NULL;
  return n;
}

int main()
{
  stack<node *> s;

  node *n;

  for (int i = 0; i < 5; i++)
  {
    n = make_a_node(i, i * i);
    s.push(n);
  }

  for (int i = 0; i < 5; i++)
  {
    cout << s.top()->x << " " << s.top()->y << endl;
    s.pop();
  }

  return 0;
}