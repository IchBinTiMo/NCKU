#include <bits/stdc++.h>
#define MAX_ROW 17
#define MAX_COL 17

using namespace std;

enum Direction // Direction
{
  East,
  South,
  North,
  West,
};

typedef struct Grid
{
  int x, y;     //1 <= x <= MAX_COL, 1 <= y <= MAX_ROW, to save the coordinates of node
  int value;    // value = 0 or 1, 0 means road and 1 means wall
  string color; // color = white, grey, or black, white means the node has not been visited yet, grey means the node is being visited, and black means the node has been visited or it cannot be passed.
} grid;

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

void go(grid m[][MAX_COL], int y, int x, int end[2], std::stack<node *> *s) // recursive function to find path to exit
{
  if ((m[y][x].value == 1 || m[y][x].color == "grey" || m[y][x].color == "black")) //return  if the current position is blocked or already discovered
  {
    return;
  }

  if (s->empty()) // push the current position to the stack
  {
    node *n = make_a_node(x, y);
    s->push(n);
  }
  else
  {
    if (s->top()->x == end[1] && s->top()->y == end[0]) // return if the top of stack is exit position
    {
      return;
    }
    else
    {
      node *n = make_a_node(x, y);
      s->push(n);
    }
  }

  m[y][x].color = "grey";
  for (int dir = Direction::East; dir <= Direction::West; dir++) // call function recursively corresponding to different direction
  {
    if (x == end[1] && y == end[0]) // return if the current position is exit position
    {
      return;
    }
    if (dir == Direction::East)
    {
      go(m, y, x + 1, end, s);
    }
    else if (dir == Direction::South)
    {
      go(m, y + 1, x, end, s);
    }
    else if (dir == Direction::North)
    {
      go(m, y - 1, x, end, s);
    }
    else if (dir == Direction::West)
    {
      go(m, y, x - 1, end, s);
    }
    if (s->top()->x == x && s->top()->y == y) // return if the top of stack is same as the current position
    {
    }
    else // push the way back to the intersection to stack
    {
      if (s->top()->x == end[1] && s->top()->y == end[0]) // return if the top of stack is exit position
      {
        return;
      }
      node *n = make_a_node(x, y);
      s->push(n);
    }
  }
  m[y][x].color = "black";
  if ((s->top()->x == end[1] && s->top()->y == end[0]) || (s->top()->x == x && s->top()->y == y)) // return if the top of stack is exit position
  {
    return;
  }
  else // push the way back to the intersection to stack
  {
    node *n = make_a_node(x, y);
    s->push(n);
  }

  return;
}

void print_stack(std::stack<node *> s, int cnt) // print the stack from bottom to top
{
  if (s.empty()) //return if the stack if empty
  {
    return;
  }
  node *n = s.top();
  s.pop();
  cnt--;
  print_stack(s, cnt); // call function recursively
  cout << cnt << ": " << n->y << " " << n->x << endl;
  s.push(n); //push the previous top to stack to preserve to order
}

void reset_map(grid m[][MAX_COL]) // function to reset the color of mep
{
  for (int i = 0; i < MAX_ROW; i++)
  {
    for (int j = 0; j < MAX_COL; j++)
    {
      if (m[i][j].value == 1)
      {
        m[i][j].color = "black";
      }
      else
      {
        m[i][j].color = "white";
      }
    }
  }
}

int main()
{
  grid maze[MAX_ROW][MAX_COL];                    //declare array to store data of each node
  int i = 0, j = 0;                               // iterator
  int startPos[2] = {1, 1}, endPos[2] = {15, 15}; //start position and end position
  string fileName, line;                          // file name and each line of the text file
  fstream file;                                   // the file which should be opened

  cout << "Enter filename: ";
  cin >> fileName;

  file.open(fileName);

  while (file >> line) // read maze map
  {
    for (j = 0; j < MAX_COL; j++)
    {
      string color;
      maze[i][j].x = j;
      maze[i][j].y = i;
      maze[i][j].value = (int)(line[j]) - 48;
      if (maze[i][j].value == 0)
      {
        maze[i][j].color = "white";
      }
      else
      {
        maze[i][j].color = "black";
      }
    }
    i++;
  }
  do
  {
    reset_map(maze); //reset the color of each grid
    int count = 0;   //count the size of path
    std::stack<node *> path;
    cout << "Enter start position: ";
    cin >> startPos[0] >> startPos[1];
    if (startPos[0] < 0 || startPos[1] < 0)
    {
      cout << "end the code.";
      break;
    }
    cout << "Enter exit position: ";
    cin >> endPos[0] >> endPos[1];
    go(maze, startPos[0], startPos[1], endPos, &path); // find way to exit in a recursively way
    count = path.size();
    node *finalPos = path.top();
    print_stack(path, count);                                 //print the path
    if (finalPos->x == endPos[0] && finalPos->y == endPos[1]) //check if escaped successfully
    {
      cout << "successfully escaped!!\n";
    }
    else
    {
      cout << "Failed to escape.\n";
    }
  } while (startPos[0] > 0 && startPos[1] > 0 && endPos[0] > 0 && endPos[1] > 0); //break the loop if enter (-1, -1)

  return 0;
}
