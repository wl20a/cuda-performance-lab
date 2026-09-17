#include <iostream>
#include <fstream>
#include <string>
#include <vector>
using namespace std;
bool isNumber(const std::string& s) {
    if (s.empty()) return false;
    int digits = 0;
    for (int i = 0; i < (int)s.size(); i++) {
        char c = s[i];
        if (c >= '0' && c <= '9') { digits++; continue; } 
        if (c == '.') continue;                            
        if (i == 0 && c == '-') continue;                  
        return false;                                      
    }
    return digits > 0;   
}
class eternal
{
    public:
    void add(double t){times.push_back(t);}
    int count()const{return times.size();}
    double mean()const
    {
        if(times.empty())
        {
            return 0;
        }
        double sum=0;
        for(double t:times) sum+=t;
        return sum/times.size();
    }
    double min() const {
        if (times.empty()) return 0;
        double m = times[0];
        for (double t : times) if (t < m) m = t;
        return m;
    }
    double max() const {
        if (times.empty()) return 0;
        double m = times[0];
        for (double t : times) if (t > m) m = t;
        return m;
    }
    private:
    vector<double>times;
};
int main()
{
    ifstream in ("data.txt");
    if(!in)
    {
        cout<<"打不开"<<endl;
        return 1;
    }
    eternal box;
    string line;
    while(getline(in,line))
    {
        if (line.empty()) continue;
        if (isNumber(line)) {
            box.add(std::stod(line));   
        } else {
            std::cout << "跳过不是数字的行: " << line << std::endl;
        }
    }
    std::cout << "样本数: " << box.count() << std::endl;
    std::cout << "平均: " << box.mean() << std::endl;
    std::cout << "最小: " << box.min() << std::endl;
    std::cout << "最大: " << box.max() << std::endl;
     return 0;
}