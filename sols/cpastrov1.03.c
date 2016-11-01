/*powered by Cristian R. Pastro
Version 1.01
Sketch
Atualizações:
*V1.00:
Alocação dinâmica de strings
*V1.01:
Reaproveitamento de memória auxiliar de outras execuções das funções
Modificação do tipo do vetor auxiliar da função returnreferences
*V1.02:
Trocado o quicksort por uma implementação própria
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define INTAM 200 /*tamanho inicial do vetor*/
#define REALLOCTAM 100 /*tamanho em que se deve aumentar na realloc*/
#define CONSTORD 0.2 /*limiar de ordenação*/

char **vauxr=NULL;

typedef struct conteudo{
	char* chave;
	char* conteudo;
}conteudo;

typedef struct listaconteudos{
	conteudo* vet;
	int ord;
	int des;
	int max;
}listaconteudos;

typedef struct tag{
	char *chave;
	char *tag;
}tag;

typedef struct listatags{
	tag* vet;
	int ord;
	int des;
	int max;
}listatags;

int comparatag(tag *x, tag *y){
	return strcmp(x->tag, y->tag);
}

 void trocatag(tag *x, tag *y){
 	tag aux;

 	aux = *x;
 	*x = *y;
 	*y = aux;
 }

void quicktags(tag *v, int esq, int dir){
	
	int i=esq, j=dir;
	int indpivo=(esq+dir)/2;
	tag pivo=v[indpivo];

	while (i<j){

		while (comparatag(&v[i], &pivo)<0)
			i++;
				
		while (comparatag(&v[j], &pivo)>0)
			j--;

		if (i<=j){
			trocatag(&v[i], &v[j]);
			i++;j--;
		}
	}

	if (j>esq)
		quicktags(v, esq, j);
	if (i<dir)
		quicktags(v, i, dir);	
}

void sortvtag(listatags *l){
	if (l->des == 0)
		return;
	quicktags(l->vet, 0, l->ord+l->des-1);
	l->ord+=l->des;
	l->des=0;
}

int comparaconteudo(conteudo *x, conteudo *y){
	return strcmp(x->chave, y->chave);
}

 void trocacont(conteudo *x, conteudo *y){
 	conteudo aux;

 	aux = *x;
 	*x = *y;
 	*y = aux;
 }

void quickcont(conteudo *v, int esq, int dir){
	
	int i=esq, j=dir;
	int indpivo=(esq+dir)/2;
	conteudo pivo=v[indpivo];

	while (i<j){

		while (comparaconteudo(&v[i], &pivo)<0)
			i++;
				
		while (comparaconteudo(&v[j], &pivo)>0)
			j--;

		if (i<=j){
			trocacont(&v[i], &v[j]);
			i++;j--;
		}
	}

	if (j>esq)
		quickcont(v, esq, j);
	if (i<dir)
		quickcont(v, i, dir);	
}

void sortvconteudo(listaconteudos *l){
	if (l->des == 0)
		return;

	quickcont(l->vet, 0, l->ord+l->des-1);
	l->ord+=l->des;
	l->des=0;
}

/*ordena quando há mais de 10% de elementos desordenados*/
void addkey(listaconteudos *l){
	if (l->des+l->ord == l->max){
		l->vet = (conteudo*)realloc(l->vet, (l->max+REALLOCTAM)*sizeof(conteudo));
		l->max+=REALLOCTAM;
	}

	scanf (" %ms %m[^\n]", &l->vet[l->des+l->ord].chave, &l->vet[l->des+l->ord].conteudo);
	l->vet[l->des+l->ord].chave[strlen(l->vet[l->des+l->ord].chave)-1]='\0';
	l->des++;
	if ((l->des> CONSTORD* l->ord) && (l->des+l->ord>100))
		sortvconteudo(l);	
}

/*ordena quando há mais de 10% de elementos desordenados*/
void taghit(listatags *l){
	if (l->des+l->ord == l->max){
		l->vet = (tag*)realloc(l->vet, (l->max+REALLOCTAM)*sizeof(tag));
		l->max+=REALLOCTAM;
	}

	scanf (" %ms %ms", &l->vet[l->des+l->ord].tag, &l->vet[l->des+l->ord].chave);
	l->des++;

	if ((l->des> CONSTORD* (l->ord)) && (l->des+l->ord>100))
		sortvtag(l);
	
}

/*busca uma chave específica no vetor de conteúdos, retorna
o indexador*/
int returnkeycontent (listaconteudos *c, char *chavebuscada){
	/*busca binária na parte ordenada*/
	int d=(c->ord)-1;
	int e=0;
	int meio = (e+d)/2;
	int i;
	while (e<=d){
		if (strcmp(c->vet[meio].chave, chavebuscada) == 0)
            return (meio);
        else{
            if (strcmp(c->vet[meio].chave, chavebuscada) < 0)
                e=meio+1;
            else
                d=meio-1;
        }
        meio=(e+d)/2;
	}

	/*busca sequencial na parte desordenada*/
	for (i=(c->ord); i< (c->ord + c->des); i++)
		if (strcmp(c->vet[i].chave, chavebuscada) == 0)
			return i;

	return -1;
}

void showtagcontent(listaconteudos *c, listatags *t){
	int d=(t->ord)-1;
	int e=0;
	int meio = (e+d)/2;
	int i;
	int ind;
	char* tagbuscada;

	scanf (" %ms", &tagbuscada);

	while (e<=d){
		if (!strcmp(t->vet[meio].tag, tagbuscada)){
            ind=returnkeycontent(c,t->vet[meio].chave);
            printf("%s -> %s\n", tagbuscada, t->vet[meio].chave);
            printf("%s :. %s\n",t->vet[meio].chave, c->vet[ind].conteudo);
            return;
		}
        else{
            if (strcmp(t->vet[meio].tag, tagbuscada) < 0)
                e=meio+1;
            else
                d=meio-1;
        }
        meio=(e+d)/2;
	}

	/*busca sequencial na parte desordenada*/
	for (i=(t->ord); i< (t->ord + t->des); i++)
		if (strcmp(t->vet[i].tag, tagbuscada) == 0){
			ind=returnkeycontent(c,t->vet[i].chave);
			printf("%s -> %s\n", tagbuscada, t->vet[i].chave);
            printf("%s :. %s\n",t->vet[i].chave, c->vet[ind].conteudo);
            return;
		}
}

void dumptags(listatags *t){
	sortvtag(t);
	int ultimoimpresso=0;/*indexador*/
	int hits=0, i;
	printf ("8<----------Begin Tag Dump----------\n");
	if (t->ord > 0)
		printf ("%s -> %s :: hits=", t->vet[0].tag, t->vet[0].chave);
	for (i=0; i< t->ord; i++){
		if (strcmp(t->vet[i].tag, t->vet[ultimoimpresso].tag) == 0){
			hits++;
		}
		else{
			printf ("%d\n", hits);
			hits=1;
			ultimoimpresso=i;
			printf ("%s -> %s :: hits=", t->vet[i].tag, t->vet[i].chave);
		}

	}
	if (hits>0) printf ("%d\n", hits);
	printf ("8<----------End   Tag Dump----------\n");
}

int comparatagchave(tag *x, tag *y){
	return strcmp(x->chave, y->chave);
}

void quicktagschave(tag *v, int esq, int dir){
	
	int i=esq, j=dir;
	int indpivo=(esq+dir)/2;
	tag pivo=v[indpivo];

	while (i<j){

		while (comparatagchave(&v[i], &pivo)<0)
			i++;
				
		while (comparatagchave(&v[j], &pivo)>0)
			j--;

		if (i<=j){
			trocatag(&v[i], &v[j]);
			i++;j--;
		}
	}

	if (j>esq)
		quicktagschave(v, esq, j);
	if (i<dir)
		quicktagschave(v, i, dir);	
}

/*ordena o vetor de tags pela tag*/
void sortvtagchave(listatags *l){
	//qsort(l->vet, l->ord+l->des, sizeof(tag), comparatagchave);
	quicktagschave(l->vet, 0, l->ord+l->des-1);
	l->des+=l->ord;
	l->ord=0;
}

int comparastring(const void *a,const void *b){
	return strcmp(*(char * const *) a, *(char * const *)b);
}

/*busca uma tag pela chave, retorna o indexador*/
/*testar com a busca recursiva*/
int buscatag(listatags *t, char* key){
	int  meio;
	int e=0;
	int d=t->des-1;
	int ind;
	meio=(e+d)/2;
	while (e<=d){
		if (!strcmp(t->vet[meio].chave, key)){
            return meio;
		}
        else{
            if (strcmp(t->vet[meio].chave, key) < 0)
                e=meio+1;
            else
                d=meio-1;
        }
        meio=(e+d)/2;
	}

	return -1;/*não achou*/
}

/*retorna quantas hits diferentes uma key teve*/
/*vetor auxiliar de ponteiros melhoraria a memória usada*/

char **auxrr=NULL;
int max=0;

 void troca(char **x, char **y){
 	char *aux;
 	aux = *x;
 	*x = *y;
 	*y = aux;
 }

void quickstring(char **v, int esq, int dir){
	int i=esq, j=dir;
	int indpivo= (esq+dir)/2;
	char *pivo=v[indpivo];
	int count;

	while (i<j){

		while (strcmp(v[i], pivo)<0)
			i++;
				
		while (strcmp(v[j], pivo)>0)
			j--;

		if (i<=j){
			troca(&v[i], &v[j]);
			i++;j--;
		}
	}

	if (j>esq)
		quickstring(v, esq, j);
	if (i<dir)
		quickstring(v, i, dir);	
}

int returnreferences(listatags *t, char* key){
	int indice, i,j;
	int n=0;
	int e, d;
	indice=buscatag(t, key);
	int ultimo=0;
	if (indice == -1)
		return 0;
	else{
		for (d=indice; d!=t->des && !strcmp(key, t->vet[d].chave); d++);
		for (e=indice; e!=-1 && !strcmp(key, t->vet[e].chave);e--);
		e++;d--;

		/*hits para a key estão no intervalo [e,d]*/
		if (auxrr == NULL)
			auxrr=(char**)malloc((d-e+1)*sizeof(char*));
		else if (max < d-e+1)
			auxrr = (char**)realloc(auxrr, (d-e+1)*sizeof(char*));

		for (i=0;i<(d-e+1);i++)
			auxrr[i]=t->vet[i+e].tag;

		quickstring (auxrr, 0, d-e);
		n=1;
		for (i=0; i<(d-e+1);i++)
			if (strcmp(auxrr[ultimo], auxrr[i]) !=0){
				n++;
				ultimo=i;
			}
	}
	return n;
}

void dumpkeys(listaconteudos *c, listatags *t){
	sortvconteudo(c);
	sortvtagchave(t);
	int i,n;
	printf ("8<----------Begin Key Dump----------\n");
	for (i=0; i< c->ord; i++){
		n=returnreferences(t, c->vet[i].chave);
		printf ("%s content=\"%s\" refs=%d\n", c->vet[i].chave, c->vet[i].conteudo, n);
	}
	printf ("8<----------End   Key Dump----------\n");
	sortvtag(t);
}

typedef struct trending{
	char *tagptr;
	int num;
}trending;

int comparabottom(const void *a,const void *b){
	trending *x=(trending*)a;
	trending *y=(trending*)b;

	if (x->num < y->num)
		return -1;
	else if (x->num > y->num)
		return 1;
	else 
		return -1*strcmp(x->tagptr, y->tagptr);
}
trending *vett=NULL;
int maxtren=0;

int comparatop(const void *a,const void *b){
	trending *x=(trending*)a;
	trending *y=(trending*)b;

	if (x->num > y->num)
		return -1;
	else if (x->num < y->num)
		return 1;
	else 
		return strcmp(x->tagptr, y->tagptr);
}

 void trocatrending(trending *x, trending *y){
 	trending aux;

 	aux = *x;
 	*x = *y;
 	*y = aux;
 }

void quicktop(trending *v, int esq, int dir){
	
	int i=esq, j=dir;
	int indpivo=(esq+dir)/2;
	trending pivo=v[indpivo];

	while (i<j){

		while (comparatop(&v[i], &pivo)<0)
			i++;
				
		while (comparatop(&v[j], &pivo)>0)
			j--;

		if (i<=j){
			trocatrending(&v[i], &v[j]);
			i++;j--;
		}
	}

	if (j>esq)
		quicktop(v, esq, j);
	if (i<dir)
		quicktop(v, i, dir);	
}

void quickbottom(trending *v, int esq, int dir){
	
	int i=esq, j=dir;
	int indpivo=(esq+dir)/2;
	trending pivo=v[indpivo];

	while (i<j){

		while (comparabottom(&v[i], &pivo)<0)
			i++;
				
		while (comparabottom(&v[j], &pivo)>0)
			j--;

		if (i<=j){
			trocatrending(&v[i], &v[j]);
			i++;j--;
		}
	}

	if (j>esq)
		quickbottom(v, esq, j);
	if (i<dir)
		quickbottom(v, i, dir);	
}

void trend(listatags *t, int n, int f){
	sortvtag(t);

	if (vett == NULL)
		vett=(trending*)calloc(t->ord, sizeof(trending));
	else if (maxtren < t->ord)
		vett=(trending*)realloc(vett, t->ord*sizeof(trending));
	
	int max=0;
	int tags=1,tagsmax,m;
	int ultimo=0;
	int i, cont=0;
	for (i=0; i<t->ord; i++){
		if (!strcmp(t->vet[i].tag,t->vet[ultimo].tag))
			cont++;
		else{
			vett[max].tagptr = t->vet[ultimo].tag;
			vett[max++].num=cont;
			ultimo=i;
			cont=1;
			tags++;
		}
	}
	vett[max].tagptr = t->vet[ultimo].tag;
	vett[max++].num=cont;
	tagsmax=(n/100.0)*tags;

	cont=0;ultimo=0;
		//printf ("---%d---\n", tagsmax);
	if (f == 1){/*top*/
		printf ("Begin %d%% top trending\n", n);
		quicktop(vett,0 ,max-1);
		i=0;
		m=1;
		while (i<tagsmax && t->ord+t->des !=0){
			i++;
			printf("%-3d %s with %d hits\n", m, vett[cont].tagptr, vett[cont].num);
			ultimo=cont;
			cont++;
			if (vett[cont].num != vett[ultimo].num){
				m++;
			}
		}
	}
	else{/*bottom*/
		printf ("Begin %d%% bottom trending\n", n);
		quickbottom(vett, 0, max-1);
		i=0;
		m=tags;i=0;
		while (i<tagsmax && t->ord+t->des !=0){
			i++;
			printf("%-3d %s with %d hits\n", m, vett[cont].tagptr, vett[cont].num);
			ultimo=cont;
			cont++;
			if (vett[cont].num != vett[ultimo].num){
				m--;
			}
		}

	}
	printf ("End Trending\n");		
}


int main(){

	int i;
	listaconteudos cont;
	cont.vet = (conteudo*)malloc(INTAM*sizeof(conteudo));
	cont.ord=0;cont.des=0;cont.max=INTAM;
	listatags tags;
	tags.vet = (tag*)malloc(INTAM*sizeof(tag));
	tags.ord=0;tags.des=0;tags.max = INTAM;

	char str1[10], str2[10];

	while (scanf (" %s %s", str1, str2) !=EOF){

		if (!strcmp(str1, "add"))
			addkey(&cont);

		else if (!strcmp(str1, "tag"))
			taghit(&tags);

		else if (!strcmp(str1,"show"))
			showtagcontent(&cont, &tags);

		else if (!strcmp(str1, "list")){
			scanf (" %s %d", str1, &i);
			if (!strcmp(str1, "top"))
				trend(&tags, i, 1);
			else 
				trend(&tags, i, 0);
		}

		else if (!strcmp(str1,"dump")){
			if (!strcmp(str2, "tags"))
				dumptags(&tags);
			else
				dumpkeys(&cont, &tags);
		}
			
	}
	free(cont.vet);
	free(tags.vet);
	return 0;
	


	

}
