#include<iostream>
using namespace std;
#include<algorithm>
#include<vector>
#include<string>
#include<list>
#include<iterator>
#include<fstream>
#include <numeric>
int main()
{
 
    ifstream in("data.txt");
    
    vector<double>v;
    vector<double>v1;    
    istream_iterator<double>is(in);
    istream_iterator<double>eof;
    while(is!=eof)
    {
        v.push_back(*is);
        ++is;
    }
    auto max=max_element(v.begin(),v.end());
    auto min=min_element(v.begin(),v.end());
    cout<<*max<<" "<<"与"<<" "<<*min<<endl;
    double sum=accumulate(v.begin(),v.end(),0.0);
    cout<<sum/v.size()<<endl;
    copy(v.begin(),v.end(),back_inserter(v1));
    sort(v1.begin(),v1.end());
    int sz=v1.size();
    if(sz%2==0)
    {
        cout<<(v1[sz/2]+v1[sz/2-1])/2.0<<endl;
    }
    else
    {
        cout<<v1[sz/2]<<endl;
    }
    
 





     return 0;
}