#include  <cstdio>
#include  <iostream>
#include  <fstream>
#include  <iomanip>
#include  <string>
#include "./dependencies/include/libpq-fe.h"

#define  PG_HOST  "127.0.0.1"
#define  PG_USER  "postgres" 
#define  PG_DB    "Waver"
#define  PG_PASS  "admin" 
#define  PG_PORT   5432

using  namespace  std;

static void stampaQuery(PGconn* conn, const char* s, bool isParametrica) {
    PGresult* res;
    if (isParametrica) {
        std::string param;
        cout << "Inserisci un codice fiscale tra quelli proposti: "; 
        cin >> param;
        const char * p = param.c_str();

        PGresult *stmt = PQprepare(conn,"query2",s, 1, NULL);
        res = PQexecPrepared(conn, "query2", 1, &p, NULL, 0, 0);

    }
    else {
        res = PQexec(conn, s);
    }

    // CONTROLLO CORRETTEZZA
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        cout << "Errore" << PQerrorMessage(conn) << endl;
        PQclear(res);
        return;
    }
    
    // STAMPA INTESTAZIONI
    for (int i = 0; i < PQnfields(res); ++i) {
        cout << left << setw(20) << setfill(' ') << PQfname(res, i) << "\t\t";
    }
    cout << endl;

    // STAMPA DATI
    for (int i = 0; i < PQntuples(res); ++i) {
        for (int j = 0; j < PQnfields(res); ++j) {
            cout << left << setw(20) << setfill(' ') << PQgetvalue(res, i, j) << "\t\t";
        }
        cout << endl;
    }
    cout << endl;
}

static void stampaIntestazione() {
    cout << "Seleziona il numero della query che vuoi stampare: " << endl;
    cout << "1. Trovare le 5 playlist pubbliche con piu' canzoni degli utenti Nati prima del 2000" << endl;
    cout << "2. Abbonati maggiorenni che guardano un concerto in cui partecipa X artista seduti in posti dispari" << endl;
    cout << "3. Il/i podcast con l'episodio piu' ascoltato dagli abbonati" << endl;
    cout << "4. la casa discografica piu' ascoltata in termini di podcast e concerti" << endl;
    cout << "5. trovare le case discografiche che hanno prodotto piu' di due album hip hop e che hanno un dirigente che guadagna piu' di 5000 euro al mese" << endl;
    cout << "6. Trovare gli artisti indipendenti (cioe' che non sono affiliati a case discografiche) che hanno partecipato a dei featuring ma non ne hanno avuti" << endl;
    cout << "-1. Per uscire dal programma" << endl;
}

int main(int argc , char **argv) {
    // CONNESSIONE AL DB
    cout  << "Start" << endl;
    char  conninfo [250];
    sprintf(conninfo, "user=%s password=%s dbname=%s hostaddr=%s port=%d", 
            PG_USER, PG_PASS, PG_DB, PG_HOST, PG_PORT);
    
    PGconn * conn = PQconnectdb (conninfo); // inizia connessione
    if (PQstatus(conn) != CONNECTION_OK) {
        cout << "Errore di connessione " << PQerrorMessage(conn);
        PQfinish(conn);
        exit(1); 
    }
    
    cout <<"Connessione avvenuta correttamente" << endl << endl;

    int numeroQueryScelta;
    while (numeroQueryScelta != -1 && cin.good()) {
        stampaIntestazione();
        cout << "La query scleta e' la: "; cin >> numeroQueryScelta; cout << endl;
        switch (numeroQueryScelta) {
        case 1:
            // stampa query 1
            cout << "Query numero 1: " << endl;
            stampaQuery(conn ,"drop view if exists aux;"
                                "create view aux as " 
                                "select pl.idPlaylist "
                                "from playlist as pl "
                                "join abbonato as ab "
                                "on pl.codiceAbbonato = ab.codiceFiscale "
                                "where pl.isPubblica = true and bdate < '2000-01-01'; "
                                "select nomePlaylist from playlist "
                                "where idPlaylist in (select idPlaylist from (select p_c.idPlaylist, count(p_c.idCanzone) "
                                                                            "from playlist_canzone as p_c "
                                                                            "join aux "
                                                                            "on aux.idPlaylist = p_c.idPlaylist "
                                                                            "group by (p_c.idPlaylist) "
                                                                            "order by count(p_c.idCanzone) desc " 
                                                                            "limit 5) as tmp);", false);
            break;
        case 2:
            {
            // stampa query 2
            cout << "Query numero 2: " << endl;
            stampaQuery(conn, "select artista.nickname, artista.codiceFiscale from artista", false);

            PQexec(conn ,   "drop view if exists concerti_degli_artisti;"
                            "create view concerti_degli_artisti as "
                            "select distinct co.idConcerto, co.titoloConcerto, ac.codiceArtista "
                            "from artista_concerto as ac "
                            "join concertoOnline as co "
                            "on ac.idConcerto = co.idConcerto "
                            "order by co.idConcerto; ");
                                
            stampaQuery(conn,   "select * "
                                "from abbonato_concerto as abc "
                                "join concerti_degli_artisti as cdax "
                                "on abc.idConcerto = cdax.idConcerto "
                                "where abc.nPostoOccupato % 2 != 0 and cdax.codiceArtista = $1::varchar "
                                "and exists (select * "
                                            "from abbonato as ab1 "
                                            "where abc.codiceabbonato = ab1.codicefiscale "
                                            "and DATE_PART('year', current_date::date) - DATE_PART('year', ab1.bdate::date) > 18 );", true);
            }
            break;
        case 3:
            // stampa query 3
            cout << "Query numero 3: " << endl;
            stampaQuery(conn ," drop view if exists episodi_maggiormente_ascoltati;"
                                "create view episodi_maggiormente_ascoltati as " 
                                "select ep.numeroEpisodio, ep.idPodcast, count(*) as quantity "
                                "from abbonato_episodio as ep "
                                "group by(ep.numeroEpisodio, ep.idPodcast); "

                                "select p.titolopodcast, ama.numeroEpisodio, ama.idpodcast "
                                "from episodi_maggiormente_ascoltati as ama "
                                "join podcast as p "
                                "on p.idpodcast = ama.idpodcast " 
                                "where quantity = (select max(quantity) "
                                                "from episodi_maggiormente_ascoltati);", false);
            break;
        case 4:
            // stampa query 4
            cout << "Query numero 4: " << endl;
            stampaQuery(conn ,"drop view if exists ascolti_episodi;"
                                "create view ascolti_episodi as " 
                                "select ae.numeroEpisodio, ae.idPodcast, count(*) as ascolti "
                                "from abbonato_episodio as ae "
                                "group by (ae.numeroEpisodio, ae.idPodcast); "
                                "drop view if exists partecipanti_al_concerto;"
                                "create view partecipanti_al_concerto as " 
                                "select ac.idConcerto, count(*) as partecipanti "
                                "from abbonato_concerto as ac "
                                "group by (ac.idConcerto); "

                                "select tmp.nome, sum(tmp.ascoltiTot) as results "
                                "from ( select cd.nome, aep.ascolti as ascoltiTot "
                                        "from ascolti_episodi as aep "
                                        "join podcast as p "
                                        "on p.idPodcast = aep.idPodcast "
                                        "join casaDiscografica as cd "
                                        "on cd.idCasa = p.idCasaDiscografica "
                                        "group by (cd.nome, aep.ascolti) "
                                        "union "
                                        "select cad.nome, pac.partecipanti as partecipantiTot "
                                        "from partecipanti_al_concerto as pac "
                                        "join concertoOnline as co "
                                        "on pac.idConcerto = co.idConcerto "
                                        "join casaDiscografica as cad "
                                        "on cad.idCasa = co.idCasaDiscografica "
                                        "group by (cad.nome, pac.partecipanti)) as tmp "
                                "group by (tmp.nome) "
                                "order by (results) desc limit 1;", false);
            break;
        case 5:
            // stampa query 5
            cout << "Query numero 5: " << endl;
            stampaQuery(conn ,"drop view if exists case_discografiche_con_album_hiphop;"
                                "create view case_discografiche_con_album_hiphop as "
                                "select a.idCasaDiscografica, a.genereAlbum, count(*) as nalbum "
                                "from album as a "
                                "where a.genereAlbum = 'Hip Hop' "
                                "group by (a.idCasaDiscografica, a.genereAlbum) "
                                "having a.idCasaDiscografica not in (select a2.idCasaDiscografica "
                                                                    "from album as a2 "
                                                                    "where a2.genereAlbum != 'Hip Hop');"

                                "select cds.nome, cds.dataFondazione, cds.cap, cds.via, cds.numeroCivico "
                                "from case_discografiche_con_album_hiphop as cdh "
                                "join responsabile as r "
                                "on r.idCasaDiscografica = cdh.idCasaDiscografica "
                                "join casaDiscografica as cds "
                                "on cds.idCasa = cdh.idCasaDiscografica "
                                "where r.stipendio >= 5000 and cdh.nalbum >= 2;", false);
            break;
        case 6:
            // stampa query 6
            cout << "Query numero 6: " << endl;
            stampaQuery(conn ,"select distinct art.codiceFiscale, art.nickname "
                                "from artista as art "
                                "join canzone as c "
                                "on c.codiceArtista = art.codiceFiscale "
                                "where art.idCasaDiscografica is null "
                                    "and art.codiceFiscale in (select ac.codiceArtista "
                                                                "from artista_canzone as ac) "
                                    "and c.idCanzone not in (select ac.idCanzone "
                                                            "from artista_canzone as ac); ", false);
            break;
        
        default:
            break;
        }
    }
}