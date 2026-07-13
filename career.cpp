#include<iostream>

using namespace std;

class Competitor{

public:

string name;

int score;

Competitor(string n,int s){

name=n;

score=s;

}

void display(){

cout<<name<<endl;

cout<<score;

}

};

int main(){

Competitor c("OpenAI",8);

c.display();

}