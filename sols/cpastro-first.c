/*This file is part of DUCKTER.
 *
 *DUCKTER is free software: you can redistribute it and/or modify
 *it under the terms of the GNU General Public License as published by
 *the Free Software Foundation, either version 3 of the License, or
 *(at your option) any later version.
 *
 *DUCKTER is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU General Public License for more details.
 *
 *You should have received a copy of the GNU General Public License
 *along with DUCKTER.  If not, see <http://www.gnu.org/licenses/>.
 */
/*powered by Cristian R. Pastro
Version 1 
Sketch
Atualizações:
*V1: Alocação dinâmica de strings
*Versão de avaliação, ainda vai ser melhorada
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#define INTAM 1000 /*tamanho inicial do vetor*/
#define REALLOCTAM 500 /*tamanho em que se deve aumentar na realloc*/
#define CONSTORD 2 /*limiar de ordenação*/

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

/*função auxiliar para ordenar tags*/
int comparatag(const void *a,const void *b){
	tag *x=(tag*)a;
	tag *y=(tag*)b;
	return strcmp(x->tag, y->tag);
}

/*ordena o vetor de tags pela tag*/
void sortvtag(listatags *l){
	if (l->des == 0)
		return;
	qsort(l->vet, l->ord+l->des, sizeof(tag), comparatag);
	l->ord+=l->des;
	l->des=0;
}

/*função auxiliar para ordenar vetor de conteúdo*/
int comparachave(const void *a,const void *b){
	conteudo *x=(conteudo*)a;
	conteudo *y=(conteudo*)b;
	return strcmp(x->chave, y->chave);
}

/*ordena o vetor de conteúdo pela chave*/
void sortvconteudo(listaconteudos *l){
	if (l->des == 0)
		return;

	qsort(l->vet, l->ord+l->des, sizeof(conteudo), comparachave);
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
	if (hits>0) printf ("%d", hits);
	printf ("\n8<----------End   Tag Dump----------\n");
}

/*função auxiliar para ordenar tags pela chave*/
int comparatagchave(const void *a,const void *b){
	tag *x=(tag*)a;
	tag *y=(tag*)b;
	return strcmp(x->chave, y->chave);
}

/*ordena o vetor de tags pela tag*/
void sortvtagchave(listatags *l){
	qsort(l->vet, l->ord+l->des, sizeof(tag), comparatagchave);
	l->des+=l->ord;
	l->ord=0;
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
/*Nota: MergeSort melhoraria o desempenho
vetor auxiliar de ponteiros melhoraria a memória usada*/
int returnreferences(listatags *t, char* key){
	int indice, i,j;
	int n=0;
	int e, d;
	indice=buscatag(t, key);
	tag *aux;
	int ultimo=0;
	if (indice == -1)
		return 0;
	else{
		for (d=indice; d!=t->des && !strcmp(key, t->vet[d].chave); d++);
		for (e=indice; e!=-1 && !strcmp(key, t->vet[e].chave);e--);
		e++;d--;

		/*hits para a key estão no intervalo [e,d]*/
		aux=(tag*)malloc((d-e+1)*sizeof(tag));

		for (i=0;i<(d-e+1);i++)
			aux[i].tag=t->vet[i+e].tag;
			//strcpy(aux[i].tag,t->vet[i+e].tag);

		qsort(aux, d-e+1, sizeof(tag), comparatag);
		n=1;
		for (i=0; i<(d-e+1);i++)
			if (strcmp(aux[ultimo].tag, aux[i].tag) !=0){
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

void trend(listatags *t, int n, int f){
	sortvtag(t);

	trending *vet;
	vet=(trending*)calloc(t->ord, sizeof(trending));
	int max=0;
	int tags=1,tagsmax,m;
	int ultimo=0;
	int i, cont=0;
	for (i=0; i<t->ord; i++){
		if (!strcmp(t->vet[i].tag,t->vet[ultimo].tag))
			cont++;
		else{
			vet[max].tagptr = t->vet[ultimo].tag;
			vet[max++].num=cont;
			ultimo=i;
			cont=1;
			tags++;
		}
	}
	vet[max].tagptr = t->vet[ultimo].tag;
	vet[max++].num=cont;
	tagsmax=(n/100.0)*tags;

	cont=0;ultimo=0;
		//printf ("---%d---\n", tagsmax);
	if (f == 1){/*top*/
		printf ("Begin %d%% top trending\n", n);
		qsort(vet, max, sizeof(trending), comparatop);
		i=0;
		m=1;
		while (i<tagsmax){
			i++;
			printf("%-3d %s with %d hits\n", m, vet[cont].tagptr, vet[cont].num);
			ultimo=cont;
			cont++;
			if (vet[cont].num != vet[ultimo].num){
				m++;
			}
		}
	}
	else{/*bottom*/
		printf ("Begin %d%% bottom trending\n", n);
		qsort(vet, max, sizeof(trending), comparabottom);
		i=0;
		m=tags;i=0;
		while (i<tagsmax){
			i++;
			printf("%-3d %s with %d hits\n", m, vet[cont].tagptr, vet[cont].num);
			ultimo=cont;
			cont++;
			if (vet[cont].num != vet[ultimo].num){
				m--;
			}
		}

	}
	free(vet);
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
