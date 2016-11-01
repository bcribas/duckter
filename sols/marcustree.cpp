#include <bits/stdc++.h>
#define mk make_pair
#define S second
#define F first
using namespace std;

map<string,pair<string,int> >Keys;//Keys conteudo, refcont
map<string,pair<string,int> >::iterator it;
map<string,pair<string,int> >Tags; // Tag keys Hits

void add_key(string k,string c){
	Keys.insert(mk(k,mk(c,0)));
}
void dump_keys(){
	printf("8<----------Begin Key Dump----------\n");
	for(it=Keys.begin();it!=Keys.end();it++){
		printf("%s content=\"%s\" refs=%d\n",it->F.c_str(),it->S.F.c_str(),it->S.S);
	}
	printf("8<----------End   Key Dump----------\n");
}
void dump_tags(){
	printf("8<----------Begin Tag Dump----------\n");
	for(it=Tags.begin();it!=Tags.end();it++){
		printf("%s -> %s hits=%d\n",it->F.c_str(),it->S.F.c_str(),it->S.S);
	}
	printf("8<----------End   Tag Dump----------\n");
}
void hit_tag(string t,string k){
	it=Tags.find(t);
	if(it!=Tags.end()){ // já encontrei a Tag?
		it->S.S++;
	}else{
		Keys[k].S++;
		Tags.insert(mk(t,mk(k,1)));
	}
}
void show_tag_content(string t){
	printf("%s -> %s\n",t.c_str(),Tags[t].F.c_str());
	string k=Tags[t].F;
	printf("%s :. %s\n",k.c_str(),Keys[k].F.c_str());
}
int main(){
	string Operacao;
	while(cin>>Operacao){
		if(Operacao=="add"){
			string type;
			cin>>type;
			if(type=="key"){
				string key,content;
				cin>>key;
				key.erase(key.size()-1);
				getline(cin,content);
				add_key(key,content);
			}
		}else if(Operacao=="dump"){
			string type;
			cin>>type;
			if(type=="keys"){
				dump_keys();
			}else if(type=="tags"){
				dump_tags();
			}
		}else if(Operacao=="tag"){
			string type;
			cin>>type;
			string tag,key;
			cin>>tag>>key;
			hit_tag(tag,key);
		}else if(Operacao=="show"){
			string type,tag;
			cin>>type>>tag;
			show_tag_content(tag);
		}
	}
	return 0;
}
