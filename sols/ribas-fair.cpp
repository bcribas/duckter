#include <stdio.h>
#include <stdlib.h>
#include <algorithm>
#include <string.h>
#include <unistd.h>

using namespace std;

struct tk_st
{
  char *id;
  char *txt;
  int ref;
};

enum lastsort_e
{
  lex,
  hitlex,
  tren,
  none
};


typedef struct ct_st
{
  struct tk_st *v;
  int size;
  int count;
  lastsort_e lastsort;
}ct_st;

#define init(ct,tipo) \
  ct.size=10, ct.count=0; \
  ct.lastsort=none; \
  ct.v=(tipo *)malloc(10*sizeof(tipo));

#define checkandresize(ct,tipo) \
  if (ct.size/2 < ct.count) \
  { \
    ct.size*=2; \
    ct.v=(tipo *)realloc(ct.v,ct.size*sizeof(tipo));\
  }

int comparal(const tk_st *a,const tk_st *b)
{
  return strcmp(a->id,b->id);
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

void ordena(tk_st *v, int p, int r, int( *compare)(const tk_st*,const tk_st*))
{
  if(p>=r) return;
  int j=separa(v,p,r,compare);
  ordena(v,p,j-1,compare);
  ordena(v,j+1,r,compare);
}

int busca(tk_st *v, int p, int r,tk_st *k, int( *compare)(const tk_st*,const tk_st*))
{
  if(p>r) return -1;
  int meio=(p+r)/2;
  int comp=compare(k,&v[meio]);
  if(comp==0)
    return meio;
  else if(comp > 0)
    return busca(v,meio+1,r,k,compare);
  else
    return busca(v,p,meio-1,k,compare);
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

void dumpkeys(ct_st *keys)
{
#ifndef __SUPERSIMPLES
  if(keys->lastsort!=lex)
#endif
    ordena(keys->v,0,keys->count-1,comparal);
  keys->lastsort=lex;

  printf("8<----------Begin Key Dump----------\n");
  for(int i=0;i<keys->count;i++)
  {
    printf("%s content=\"%s\" refs=%d\n",keys->v[i].id,keys->v[i].txt,
                                         keys->v[i].ref);
  }
  printf("8<----------End   Key Dump----------\n");
}

void dumptags(ct_st *keys)
{
#ifndef __SUPERSIMPLES
  if(keys->lastsort!=lex)
#endif
    ordena(keys->v,0,keys->count-1,comparal);
  keys->lastsort=lex;

  printf("8<----------Begin Tag Dump----------\n");
  for(int i=0;i<keys->count;i++)
  {
    printf("%s -> %s :: hits=%d\n",keys->v[i].id,keys->v[i].txt,
                                         keys->v[i].ref);
  }
  printf("8<----------End   Tag Dump----------\n");
}

void addcmd(char *cmd, ct_st *keys, ct_st *tags)
{
  if(strcmp(cmd,"key")==0)
  {
    char *chave,*content;
    struct tk_st t;
    scanf(" %ms %m[^\n]", &chave,&content);
    chave[strlen(chave)-1]=0;
    t.id=chave;
    t.txt=content;
    t.ref=0;
    checkandresize((*keys), tk_st);
    keys->v[keys->count++]=t;
    keys->lastsort=none;
  }
  else if(strcmp(cmd,"tag")==0)
  {
    char *tag,*point;
    struct tk_st n;
    scanf(" %ms %m[^\n]", &tag,&point);
    n.id=tag;
#ifndef __SUPERSIMPLES
    if(tags->lastsort!=lex)
#endif
      ordena(tags->v,0,tags->count-1,comparal);
    tags->lastsort=lex;

    int b=busca(tags->v,0,tags->count-1,&n,comparal);
    if(b==-1)
    {
      n.ref=1;
      n.txt=point;
      struct tk_st t; t.id=point;
#ifndef __SUPERSIMPLES
      if(keys->lastsort!=lex)
#endif
        ordena(keys->v,0,keys->count-1,comparal);
      keys->lastsort=lex;
      keys->v[busca(keys->v,0,keys->count-1,&t,comparal)].ref++;
      checkandresize((*tags),tk_st);
      tags->v[tags->count++]=n;
      tags->lastsort=none;
    }
    else
    {
      tags->v[b].ref++;
      free(point);
      free(tag);
    }
  }
}

void trending(ct_st *tags)
{
  char *where; int p;
  scanf(" %ms %d",&where,&p);
  printf("Begin %d%% %s trending\n",p,where);
  //printf("-->aqui %d %d\n",p,tags->count);
  //printf("-->aqui\n");
  tags->lastsort=tren;
  if(!strcmp(where,"top"))
  {
    p=(p*tags->count)/100;
    topk(tags->v,0,tags->count-1,p,comparaHL);
    int i;
    ordena(tags->v,0,p,comparaHL);
    int pos=1;
    int lasthitcount=tags->v[0].ref;
    printf("%-3d %s with %d hits\n",1,tags->v[0].id,tags->v[0].ref);
    for(i=1;i<p;i++)
    {
      if(tags->v[i].ref!=lasthitcount)
      {
        pos++;
        lasthitcount=tags->v[i].ref;
      }
      printf("%-3d %s with %d hits\n",pos,tags->v[i].id,tags->v[i].ref);
    }
  }
  else
  {
    p=(p*tags->count)/100;
    topk(tags->v,0,tags->count-1,tags->count-p,comparaHL);
    int i;
    ordena(tags->v,p,tags->count-1,comparaHL);
    int pos=tags->count;
    int lasthitcount=tags->v[tags->count-1].ref;
    printf("%-3d %s with %d hits\n",pos,tags->v[tags->count-1].id,tags->v[tags->count-1].ref);
    for(i=tags->count-2;i>=tags->count-p;i--)
    {
      if(tags->v[i].ref!=lasthitcount)
      {
        pos--;
        lasthitcount=tags->v[i].ref;
      }
      printf("%-3d %s with %d hits\n",pos,tags->v[i].id,tags->v[i].ref);
    }
  }
  free(where);
  printf("End Trending\n");

}

void showtagcontent(ct_st *keys,ct_st *tags)
{
  char *buf;
  scanf(" %ms",&buf);
  tk_st n;
  n.id=buf;
#ifndef __SUPERSIMPLES
  if(tags->lastsort!=lex)
#endif
    ordena(tags->v,0,tags->count-1,comparal);
  tags->lastsort=lex;
  int b=busca(tags->v,0,tags->count-1,&n,comparal);
  if(b==-1)
  {
    printf("Oops, tag \"%s\" not found. Aborting\n",buf);
    exit(1);
  }
  printf("%s -> %s\n",buf,tags->v[b].txt);
  n.id=tags->v[b].txt;
  b=busca(keys->v,0,keys->count-1,&n,comparal);
  printf("%s :. %s\n",keys->v[b].id,keys->v[b].txt);
  free(buf);
}

#if 0
void rotateday(auto &keys,auto &tags)
{
  stack<char *> toremove;
  for(auto it=tags.begin();it!=tags.end();it++)
  {
    if(it->second.hits==0)
      toremove.push(it->first);
    else
      it->second.hits=0;
  }

  while(!toremove.empty())
  {
    keys[tags[toremove.top()].key].ref--;
    tags.erase(tags.find(toremove.top()));
    printf("Removed tag: %s\n",toremove.top());
    toremove.pop();
  }

}
#endif

int main(void)
{
  ct_st keys;
  ct_st tags;
  init(keys,tk_st);
  init(tags,tk_st);

  char cmd1[50],cmd2[50];
  while(scanf(" %s %s",cmd1,cmd2)==2)
  {
    if(strcmp(cmd1,"add")==0 && strcmp(cmd2,"key")==0)
      addcmd(cmd2,&keys,&tags);
    else if(strcmp(cmd1,"tag")==0 && strcmp(cmd2,"hit")==0)
      addcmd(cmd1,&keys,&tags);
    else if(strcmp(cmd1,"list")==0 && strcmp(cmd2,"trending")==0)
      trending(&tags);
#if 0
    else if(!strcmp(cmd1,"new") && !strcmp(cmd2,"day"))
      rotateday(keys,tags);
#endif
    else if(!strcmp(cmd1,"show"))
      showtagcontent(&keys,&tags);
    else if(!strcmp(cmd1,"dump"))
    {
      if(!strcmp(cmd2,"keys"))
        dumpkeys(&keys);
      else
        dumptags(&tags);
    }
    else
    {
      printf("Unknown command: %s %s\n",cmd1,cmd2);
      printf("  .: Aborting\n");
      exit(1);
    }
  }
  return 0;
}
