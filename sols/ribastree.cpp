#include <stdio.h>
#include <map>
#include <algorithm>
#include <string.h>
#include <list>
#include <stack>

using namespace std;


struct ltstr
{
  bool operator()(const char* s1, const char* s2) const
  {
    return strcmp(s1, s2) < 0;
  }
};

struct tk_st
{
  char *id;
  char *txt;
  int ref;
};

class comparaHLb
{
public:
  bool operator()(const tk_st &a, const tk_st &b) const
  {
    int ret=0;
    if(a.ref > b.ref) ret=-1;
    else if(a.ref < b.ref) ret=1;
    else ret=(strcmp(a.id,b.id));
    return ret<0;
  }
};


struct tag_st
{
  char *key;
  int hits;
};

struct key_st
{
  char *txt;
  int ref;
};

void dumpkeys(auto &keys)
{
  printf("8<----------Begin Key Dump----------\n");
  auto fim=keys.end();
  for(auto it=keys.begin();it!=fim;it++)
  {
    printf("%s content=\"%s\" refs=%d\n",it->first,it->second.txt,it->second.ref);
  }
  printf("8<----------End   Key Dump----------\n");

}

void dumptags(auto &tags)
{
  printf("8<----------Begin Tag Dump----------\n");
  auto fim=tags.end();
  for(auto it=tags.begin();it!=fim;it++)
  {
    printf("%s -> %s :: hits=%d\n",it->first,it->second.key, it->second.hits);
  }
  printf("8<----------End   Tag Dump----------\n");
}

void addcmd(char *cmd, auto &keys, auto &tags)
{
  if(strcmp(cmd,"key")==0)
  {
    char *chave,*content;
    struct key_st t;
    scanf(" %ms %m[^\n]", &chave,&content);
    chave[strlen(chave)-1]=0;
    t.txt=content;
    t.ref=0;
    keys[chave]=t;
  }
  else if(strcmp(cmd,"tag")==0)
  {
    char *tag,*point;
    scanf(" %ms %m[^\n]", &tag,&point);
    if(tags.find(tag)==tags.end())
    {
      keys[point].ref++;
      struct tag_st t;
      t.key=point;
      t.hits=1;
      tags[tag]=t;
    }
    else
    {
      tags[tag].hits++;
      free(point);
      free(tag);
    }
  }
}

int comparaHL(const tk_st *a, const tk_st *b)
{
  if(a->ref > b->ref) return -1;
  else if(a->ref < b->ref) return 1;
  else return (strcmp(a->id,b->id));
}

int separa(tk_st *v, int p, int r, int( *compare)(const tk_st*,const tk_st*))
{

  if(p==r) return p;
  tk_st t;
  tk_st tc;
#ifndef __DUMBPIVOT
  int a,b,c;
  a=lrand48()%(r-p)+p;
  b=lrand48()%(r-p)+p;
  c=lrand48()%(r-p)+p;
  int x;
  if(compare(&v[a],&v[b])>0)
    x=a,a=b,b=x;

  if(compare(&v[b],&v[c])>0)
    x=b,b=c,c=x;

  if(compare(&v[a],&v[b])>0)
    x=a,a=b,b=x;

  t=v[b];
  v[b]=v[p];
  v[p]=t;
#endif
  tc=v[p];
  int i=p+1,j=r;
  while(i<=j)
  {
    if(compare(&v[i],&tc)<=0) i++;
    else if(compare(&tc,&v[j])<0) j--;
    else
    {
      t=v[i],v[i]=v[j],v[j]=t;
      i++,j--;
    }
  }
  v[p]=v[j],v[j]=tc;
  return j;

}

int topk(tk_st *v, int p, int r,int k, int( *compare)(const tk_st*,const tk_st*))
{
  //printf(":topk p=%d r=%d\n",p,r);
  if(p>r) return -1;
  int j=separa(v,p,r,compare);
  if(j==k)
    return j;
  else if(j < k)
    return topk(v,j+1,r,k,compare);
  else
    return topk(v,p,j-1,k,compare);
}

void trending(auto &tags)
{
  char *where; int p;
  tk_st *v=(tk_st*)malloc(sizeof(tk_st)*(tags.size()+2));
  int i=0;
  auto fim=tags.end();
  for(auto it=tags.begin();it!=fim;it++,i++)
  {
    v[i].id=it->first;
    v[i].ref=it->second.hits;
  }
  scanf(" %ms %d",&where,&p);
  printf("Begin %d%% %s trending\n",p,where);
  p=(p*(int)tags.size())/100;
  if(!strcmp(where,"top") && p>0)
  {
    //topk(v,0,tags.size()-1,p,comparaHL);
    int i;
    sort(&v[0],&v[tags.size()],comparaHLb());
    int pos=1;
    int lasthitcount=v[0].ref;
    printf("%-3d %s with %d hits\n",1,v[0].id,v[0].ref);
    for(i=1;i<p;i++)
    {
      if(v[i].ref!=lasthitcount)
      {
        pos++;
        lasthitcount=v[i].ref;
      }
      printf("%-3d %s with %d hits\n",pos,v[i].id,v[i].ref);
    }
  }
  else if(p>0)
  {
    //topk(v,0,tags.size()-1,tags.size()-p,comparaHL);
    int i;
    sort(&v[0],&v[tags.size()],comparaHLb());
    int pos=tags.size();
    int lasthitcount=v[tags.size()-1].ref;
    printf("%-3d %s with %d hits\n",pos,v[tags.size()-1].id,v[tags.size()-1].ref);
    for(i=tags.size()-2;i>=tags.size()-(unsigned int)p && i>=0;i--)
    {
      if(v[i].ref!=lasthitcount)
      {
        pos--;
        lasthitcount=v[i].ref;
      }
      printf("%-3d %s with %d hits\n",pos,v[i].id,v[i].ref);
    }
  }
  free(where);
  free(v);

  printf("End Trending\n");
}

void showtagcontent(auto &keys,auto &tags)
{
  char buf[1000];
  scanf(" %s",buf);
  auto t=tags.find(buf);
  if(t==tags.end())
  {
    printf("Oops, tag \"%s\" not found\n",buf);
    return;
  }
  char *point=t->second.key;
  printf("%s -> %s\n",buf,point);
  printf("%s :. %s\n",point,keys[point].txt);
}

void rotateday(auto &keys,auto &tags)
{
  stack<char *> toremove;
  auto fim=tags.end();
  for(auto it=tags.begin();it!=fim;it++)
  {
    if(it->second.hits==0)
      toremove.push(it->first);
    else
      it->second.hits=0;
  }

  while(!toremove.empty())
  {
    auto t=tags.find(toremove.top());
    keys[t->second.key].ref--;
    free(t->second.key);
    tags.erase(t);
    free(toremove.top());
    toremove.pop();
  }

}

int main(void)
{
  map<char *, struct key_st,ltstr> keys;
  map<char *, struct tag_st,ltstr> tags;

  char cmd1[50],cmd2[50];
  while(scanf(" %s %s",cmd1,cmd2)==2)
  {
    if(strcmp(cmd1,"add")==0)
      addcmd(cmd2,keys,tags);
    else if(strcmp(cmd1,"tag")==0 && strcmp(cmd2,"hit")==0)
      addcmd(cmd1,keys,tags);
    else if(!strcmp(cmd1,"new") && !strcmp(cmd2,"day"))
      rotateday(keys,tags);
    else if(strcmp(cmd1,"list")==0 && strcmp(cmd2,"trending")==0)
      trending(tags);
    else if(!strcmp(cmd1,"show"))
      showtagcontent(keys,tags);
    else if(!strcmp(cmd1,"dump"))
    {
      if(!strcmp(cmd2,"keys"))
        dumpkeys(keys);
      else
        dumptags(tags);
    }
    else
    {
      printf("Unknown command: %s %s\n",cmd1,cmd2);
      printf("  .: Aborting\n");
      exit(1);
    }
  }
#if 0
  printf("8<------Dumping after quit for debug purposes-----\n");
  dumpkeys(keys);
  dumptags(tags);
  printf("8<------------------------------------------------\n");
#endif
}
