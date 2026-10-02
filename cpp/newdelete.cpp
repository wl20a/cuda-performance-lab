#include<iostream>
using namespace std;
#include<algorithm>
#include<vector>
#include<string>
#include<list>
#include<iterator>
#include<fstream>
#include<memory>
typedef std::vector<int> vec;
/*shared_ptr<vector<int>> fun()
{
    return shared_ptr<vector<int>>(new vector<int>);
     //return make_shared<vector<int>>();
}*/
vec* fun()
{
    return new vec;
}
void cin1(vec *v)
{
  int x;
  while(cin>>x)
    {
        v->push_back(x);
    }
}
void cout1(const vec*v)
{
   for(auto &a:*v)
    {
        cout<<a<<" ";
    }
}
int main()
{
    vec *v = fun();   
    cin1(v);
    cout1(v);
    delete v;         
    return 0;
}
