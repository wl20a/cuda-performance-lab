#include<iostream>
using namespace std;
#include<algorithm>
#include<vector>
#include<string>
#include<list>
#include<iterator>
#include<fstream>
void biggest(vector<string>&s,vector<string>::size_type sz)
{
    sort(s.begin(),s.end());
    auto it =unique(s.begin(),s.end());
    s.erase(it,s.end());
    stable_sort(s.begin(),s.end(),[](const string &a,const string &b){return a.size()>b.size();});
    auto af=find_if(s.begin(),s.end(),[sz](const string &a){return a.size()>=sz;});
    auto count=s.end()-af;
    cout<<count<<endl;
    for_each(af,s.end(),[](const string &a){cout<<a<<" ";});

}
int main()
{
    /*
    auto f=[](const int &a,const int &b){return a+b;};
    ostream &b=cout;
    b<<f(3,4)<<endl;
    */

    /*
    int a=10;
    auto sum=[a](int x)->int{return a+x;};
    ostream &b=cout;
    b<<sum(5)<<endl;
    b<<sum(15)<<endl;
    */

        
    return 0;
}