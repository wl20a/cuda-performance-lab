#include<iostream>
using namespace std;
#include<algorithm>
#include<vector>
#include<string>
#include<list>
#include<iterator>
#include<fstream>
void find0(list<int>&q)
{

}
int main()
{
    vector<int>v{1,2,3,5,0,2,5,6,0,6,7,9};
    list<int>s{1,2,3,5,0,2,5,6,0,6,7,9};
    list<int>q;
    ostream &a=cout;

    for(auto it=v.rbegin();it!=v.rend();it++)
    {
        a<<*it<<" ";
    } 
    a<<endl;

    for(auto m=v.end()-1;m>=v.begin();m--)
    {
        a<<*m<<" ";
    }
    a<<endl;

    auto it=find(s.rbegin(),s.rend(),0);

    if(it!=s.rend())
    {
        a<<"找到了"<<endl;
    }

    auto ad=prev(it.base());
    a<<*ad<<" ";

    a<<endl;
    
    reverse_copy(v.begin()+2,v.begin()+6,back_inserter(q));
    for(int m:q)
    {
        a<<m<<" ";
    }
    
    
    return 0;
}