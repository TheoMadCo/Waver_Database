drop table if exists abbonato 			cascade;
drop table if exists playlist 			cascade;
drop table if exists casaDiscografica 	cascade;
drop table if exists artista 			cascade;
drop table if exists responsabile 		cascade;
drop table if exists album 				cascade;
drop table if exists canzone 			cascade;
drop table if exists concertoOnline 	cascade;
drop table if exists podcast 			cascade;
drop table if exists episodio 			cascade;
drop table if exists cellulare 			cascade;
drop table if exists abbonato_concerto 	cascade;
drop table if exists abbonato_playlist 	cascade;
drop table if exists abbonato_episodio  cascade;
drop table if exists artista_canzone    cascade;
drop table if exists artista_concerto   cascade;
drop table if exists playlist_canzone   cascade;

/* CREAZIONE TABELLE */
create table abbonato (
    codiceFiscale       varchar(16)     primary key,
    nome                varchar(30)     not null,
    cognome             varchar(40)     not null,
    email               varchar(60)     not null,
    password            varchar(100)    not null,
    bdate               date            not null,
    isPremium           boolean         not null
);

create table playlist (
    idPlaylist          serial          primary key,
    codiceAbbonato      varchar(16)     not null,
    nomePlaylist        varchar(50)     not null,
    dataCreazione       date            not null,
    generePlaylist      varchar(50)     not null,
    isPubblica          boolean         not null,
    foreign key (codiceAbbonato) references abbonato(codiceFiscale)
);

create table casaDiscografica (
    idCasa              serial         primary key,
    nome                varchar(70)     not null,
    dataFondazione      date            not null,
    cap                 varchar(5)      not null,
    via                 varchar(100)    not null,
    numeroCivico        varchar(5)      not null
);

create table artista (
    codiceFiscale       varchar(16)     primary key,
    nome                varchar(30)     not null,
    cognome             varchar(40)     not null,
    email               varchar(60)     not null,
    nickname            varchar(100)    not null,
    password            varchar(100)    not null,
    bdate               date            not null,
    partitaIVA          varchar(11)     not null,
    idCasaDiscografica  integer         ,    
    foreign key (idCasaDiscografica) references casaDiscografica(idCasa)
);

create table responsabile (
    codiceFiscale       varchar(16)     primary key,
    nome                varchar(30)     not null,
    cognome             varchar(40)     not null,
    email               varchar(60)     not null,
    password            varchar(100)    not null,
    bdate               date            not null,
    stipendio           decimal(10,3)   not null,
    idCasaDiscografica  integer         not null,
    foreign key (idCasaDiscografica) references casaDiscografica(idCasa)   
);

create table cellulare (
    numero              varchar(10)     primary key,
    codiceResponsabile  varchar(16)     not null,
    foreign key (codiceResponsabile) references responsabile(codiceFiscale)
);

create table album (
    idAlbum             serial         primary key,
    idCasaDiscografica  integer         not null,
    titoloAlbum         varchar(70)     not null,
    dataRilascio        date            not null,
    posizioneClassifica integer         ,
    durataTotale        integer         not null, /* durata espressa in secondi*/
    genereAlbum         varchar(50)     not null,
    foreign key (idCasaDiscografica) references casaDiscografica(idCasa) 
);


create table canzone (
    idCanzone           serial         primary key,
    codiceArtista       varchar(16)     not null,
    titoloCanzone       varchar(30)     not null,
    dataDrop            date            not null,
    durata              integer         not null, /* durata espressa in secondi*/
    genereCanzone       varchar(50)     not null,
    idAlbum             integer         ,
    foreign key (codiceArtista) references artista(codiceFiscale),
    foreign key (idAlbum)   references album(idAlbum)
);


create table concertoOnline (
    idConcerto          serial          primary key,
    idCasaDiscografica  integer         not null,
    titoloConcerto      varchar(30)     not null,
    dataConcerto        date            not null,
    prezzoBiglietto     decimal(6,2)    not null,
    numeroPostiMax      integer         not null,
    foreign key (idCasaDiscografica) references casaDiscografica(idCasa)
);

create table podcast (
    idPodcast           serial         primary key,
    idCasaDiscografica  integer         not null,
    titoloPodcast       varchar(30)     not null,
    dataCaricamento     date            not null,
    riassunto           varchar(1000)   ,
    foreign key (idCasaDiscografica) references casaDiscografica(idCasa)
);

create table episodio (
    numeroEpisodio      integer         ,
    idPodcast           integer         ,
    titoloEpisodio      varchar(30)     not null,
    durata              integer         not null,
    descrizione         varchar(500)    ,
    primary key (numeroEpisodio, idPodcast),
    foreign key (idPodcast) references podcast(idPodcast)
);

create table abbonato_playlist (
    codiceAbbonato      varchar(16)     ,
    idPlaylist          integer         ,
    primary key (codiceAbbonato, idPlaylist),
    foreign key (codiceAbbonato) references abbonato(codiceFiscale),
    foreign key (idPlaylist)     references playlist(idPlaylist)
);

create table abbonato_concerto (
    codiceAbbonato      varchar(16)     ,
    idConcerto          integer         ,
    nPostoOccupato      integer         not null,
    primary key (codiceAbbonato, idConcerto),
    foreign key (codiceAbbonato) references abbonato(codiceFiscale),
    foreign key (idConcerto) references concertoOnline(idConcerto)
);

create table abbonato_episodio (
    codiceAbbonato      varchar(16)     ,
    numeroEpisodio      integer         ,
    idPodcast           integer         ,
    primary key (codiceAbbonato, numeroEpisodio, idPodcast),
    foreign key (codiceAbbonato) references abbonato(codiceFiscale),
    foreign key (numeroEpisodio, idPodcast) references episodio(numeroEpisodio, idPodcast)
);

create table artista_canzone (
    codiceArtista       varchar(16)     ,
    idCanzone           integer         ,
    dataFeaturing       date            not null,
    primary key (codiceArtista, idCanzone),
    foreign key (codiceArtista) references artista(codiceFiscale),
    foreign key (idCanzone) references canzone(idCanzone)
);

create table artista_concerto (
    codiceArtista       varchar(16)     ,
    idConcerto          integer         ,
    primary key (codiceArtista, idConcerto),
    foreign key (codiceArtista) references artista(codiceFiscale),
    foreign key (idConcerto) references concertoOnline(idConcerto)
);

create table playlist_canzone (
    idPlaylist          integer        ,
    idCanzone           integer        ,
    primary key (idPlaylist, idCanzone),
    foreign key (idPlaylist) references playlist(idPlaylist),
    foreign key (idCanzone) references canzone(idCanzone)
);

/* POPOLAZIONE TABELLE*/
alter table abbonato disable trigger all;
alter table playlist disable trigger all;
alter table casaDiscografica disable trigger all;
alter table artista disable trigger all;
alter table responsabile disable trigger all;
alter table cellulare disable trigger all;
alter table album disable trigger all;
alter table canzone disable trigger all;
alter table concertoOnline disable trigger all;
alter table podcast disable trigger all;
alter table episodio disable trigger all;
alter table abbonato_concerto disable trigger all;
alter table abbonato_playlist disable trigger all;
alter table abbonato_episodio disable trigger all;
alter table artista_concerto disable trigger all;
alter table artista_canzone disable trigger all;
alter table playlist_canzone disable trigger all;

insert into abbonato (codiceFiscale, nome, cognome, email, password, bdate, isPremium) values
('PDSMLS33C54G392E','Maria','Pirelli','maria.pirelli@yahoo.it','E2E2E26E3C86E9F8','1933-03-14', true),
('ZFVCHF67D49A551E','Claudio','Zampieri','claudio.zampieri@gmail.com','3b6!GKM!Y@y%BctrWzjK','1967-04-9', false),
('TQRXSC51B61F004G','Sara','trombolato','sara.trombolato@gmail.com','fy$9F2LcaiV5MiDfKJta','1998-06-1', false),
('KSMBVU77A06B812F','Bernardo','mazzon','bernardo.mazzon@gmail.com','ZCuQ%igqRh@d&G6Dp&y3','1977-01-6', true),
('VMZLXK68H69C177C','Laura','vettore','laura.vettore@gmail.com','gvxmYk&pM$9pWJQMV887','2003-11-23', true),
('BHPVKV53R49G811Z','Vittorio','Parini','vittorio.parini@alice.it','MT^$26y%','2001-08-13', false),
('NNZLHH81H55L290Q','Ludovica','Nizzetto','ludovica.nizzetto@gmail.it','LJ8WVGHYg$ebT','2000-06-15', true),
('RGFYHP69S50H242Q','Giovanni','Cocco','giovanni.cocco@studenti.unipd.it','rFsnf$px4fLCzv84uR#8TGw','1997-01-22', false),
('RJGSLW73R45D386Y','Francesco','Totti','francesco.totti@gmail.com','2#VxwprZim^BXF#Wh64h','1976-09-27', false),
('VCDZYL54T65B644C','Roberto','Stevanardi','roberto.stevanardi@libero.it','87kjqgd687sadhk','1999-08-08', true),
('LWCRVF88D29A346Q','Francesco','Mivi','francesco.mivi@live.com','786234kjhgd#@dasda', '1989-07-01', false),
('FGPPBG48R41A281H','Luciana','Violi','luciana.violi@gmail.com','GIUADhso892w#@4','2000-01-01',true),
('NZMVVQ32B23E761Z','Nunzia','Zerini','nunzia.zerini@gmail.com','jhdlkjahs792òksdf@#¡?','2003-04-02',true),
('RCKTGC79M28Z611Y','Roberto','Zanardi','roberto.zanardi@live.it','lhda&%sdre98234','2002-01-02',true);



insert into playlist (codiceAbbonato, nomePlaylist, dataCreazione, generePlaylist, isPubblica) values
('PDSMLS33C54G392E','Halloween','2019-10-30','mixed',false),
('PDSMLS33C54G392E','Best of hip hop 2019','2020-01-1','hip hop',true),
('KSMBVU77A06B812F','EDM','2016-05-22','EDM',true),
('RJGSLW73R45D386Y','Classici anni 90','2017-07-10','mixed',false),
('BHPVKV53R49G811Z','Compleanno Tommaso','2018-09-2','Goa',false),
('BHPVKV53R49G811Z','TomorrowLand','2019-04-16','Elettronica/Dubstep',true),
('LWCRVF88D29A346Q','Ricordi di una vita passata','2020-12-12','indie',true),
('RCKTGC79M28Z611Y','Rocce spigolose','2018-09-04','rock',true),
('NNZLHH81H55L290Q','Metallo ferroso','2018-05-09','metal',false),
('VCDZYL54T65B644C','sksk','2019-10-30','trap',true),
('LWCRVF88D29A346Q','bling bling','2017-04-02','hip hop',true);




insert into casaDiscografica (nome, dataFondazione, cap, via, numeroCivico) values
('Death Row Records','1991-02-03', '58010', 'Via Pietro Nenni', '11'),
('Tasty records','1972-04-13', '26013', 'Via Ix Novembre 1989', '18'),
('Beat 2000','1925-12-10', '13048', 'C.So Santo Ignazio', '18'),
('Controsenso Villareggese','2000-10-12', '10030', 'Via Maestra', '89A'),
('M.C. Foligno Enduro Team','2020-07-21', '06034', 'Dario, Signorelli', '63'),
('Lazy Pug','1990-09-07','32100','Via Mestro caravaggio','21'),
('Lovely vibes bleeding hearts','2021-01-01','31898','P.zza Martiri','64B');

insert into artista (codiceFiscale, nome, cognome, email, nickname ,password, bdate, partitaIVA, idCasaDiscografica) values
('RKRRRV63B59B376Q','Marco','Bustaffa','m.bustaffa@gmail.com','Busta','%CZeLVXBWgkXT2HLvquh7Jy94&5L6!^$','2000-12-24','91045440541',1),
('SSGRME81R21G922S','Sergio','Lerme','sergio.lerme@gmail.com','Luis','s2m!7zDFm^YGBi3N%2FH','1998-11-5','02552970283',4),
('VSXTLT77M43A855D','Emanuele','Sanco','emanuele.sanco@gmail.com','Snaco','e8utRn63%Ww5CPJ%KTG5','1998-11-30','02944870043',5),
('HJLRTL83S12G430B','Giacomo','Galiazzo','giacomo.sanco@gmail.com','Gali','ZW@#a3$d4MTBCVvHmL3M','2000-06-18','09160920014',3),
('FHVCNB86C19A741W','Robert','Andone','robert.andone@gmail.com','Anduan','2d&Gn7iY8gkZnpWU79CW','2000-04-4','92235260921',1),
('QLLQRT86M18B051E','Franco','Franchino','franco.franchino@gmail.com','Franchino','2S$XYz9zVSbXoM9@X7gk','1953-02-16','11367400154',2),
('VTNMPN34E48Z612K','Martijn','Gerard','martin.garrix@gmail.com','Martin Garrix','NUQJxzvcWSLAr&F6Z%bq','1996-05-14','01521640035',2),
('HKONSK94C58B914D','Amico','Frizz','amico.frizz@indipendente.com','Sdrumox','9i^P%Wx%u63%!FxP','1999-04-10','86334519757',null),
('JPLRQP78C17A102B','Gustav','Cark','gustav.cark@gmail.com','Crick Cark','gsad6832h!!xcz','1989-02-12','45807720318',6),
('HBPPMR83P08D310X','Lerk','Lericsoon','lerkilerki@verizon.org','CXXson','ha835bfw]##fsd','2001-09-11','42035220740',null),
('DDMZKS62B60I911X','Danyl','Steffan','daniloss@live.com','Danyl','dgai7632gjhgh','1978-11-12','36075900229',7),
('RZJPTF86C31C656C','Richard','Gold','richyrich@gmail.com','Richy the rich','@123ricirici1234','1980-07-05','68685720291',6),
('VZJSBW42D14G415X','John','Leggendario','legendaryborny@live.com','!legend','fs68d7fy234@#@sf','1994-04-04','52803680298',null);

insert into album (idCasaDiscografica, dataRilascio, titoloAlbum, posizioneClassifica, durataTotale, genereAlbum) values
(1,'1996-02-13','all eyez on me',1,2700,'Hip Hop'),
(2,'2008-01-20','Folklore',10,3600,'Pop'),
(3,'2020-06-3','RTJ4',5,3900,'Regaetton'),
(4,'2020-06-18','Punisher',47,3000,'indie'),
(5,'2012-09-4','night vision ',3,4500,'Rock'),
(1,'1993-11-23','Doggystyle',2,3675,'Hip Hop'),
(6,'2000-01-01','Puggy dancing',34,4500,'Hip Hop'),
(6,'2004-05-05','Bass Stupid King',1,'4500','Hip Hop'),
(7,'2021-01-01','End of s*** year',4,'3900','Pop');

insert into canzone (codiceArtista, titoloCanzone, dataDrop, durata, genereCanzone, idAlbum) values
('RKRRRV63B59B376Q','Tone Deaf','2020-12-18',236,'Hip Hop', 1),
('RKRRRV63B59B376Q','Higher','2020-12-18',212,'Hip Hop', 6),
('SSGRME81R21G922S','Beef','2018-09-20',182,'Regaetton', null),
('SSGRME81R21G922S','Shhh(pew pew)','2019-11-09',114,'indie', 4),
('SSGRME81R21G922S','She Knows this','2019-11-09',227,'R&B', 4),
('VSXTLT77M43A855D','Fu**k it up','2019-03-16',164,'Rock', 5),
('VSXTLT77M43A855D','Pasticche','2019-03-16',197,'Rock/Hip Hop', 5),
('HJLRTL83S12G430B','$€ Freestyle','2020-11-20',184,'Trap/regaetton', 3),
('HJLRTL83S12G430B','Baby','2020-11-20',193,'Trap/regaetton', 3),
('HJLRTL83S12G430B','Dende','2017-07-13',209,'Trap', null),
('FHVCNB86C19A741W','Disturbia','2013-03-21',209,'Pop', null),
('FHVCNB86C19A741W','Whoopty','2020-04-13',123,'Trap', 1),
('QLLQRT86M18B051E','I will find you','2007-09-15',84,'Elettronica', 2),
('QLLQRT86M18B051E','999-Imperiale remix','2015-06-28',324,'Elettronica', null),
('VTNMPN34E48Z612K','In the name of love','2017-07-22',223,'Pop', 2),
('HKONSK94C58B914D','La vita di Frizz','2020-12-28',600,'Funk', null),
('VZJSBW42D14G415X','How Legends Born','1999-08-07',600,'Hip Hop',null),
('VZJSBW42D14G415X','How Legends Born 2.5','2000-08-07',600,'Hip Hop',null),
('RZJPTF86C31C656C','Put eyes on pug','2000-01-01',400,'Hip Hop',7),
('RZJPTF86C31C656C','Put eyes on the dog','2000-01-01',450,'Hip Hop',7),
('RZJPTF86C31C656C','Man come see the f*** pug','2000-01-01',460,'Hip Hop',7),
('DDMZKS62B60I911X','Trobazky Malazky','2001-12-12',730,'Classical',null),
('DDMZKS62B60I911X','Lubronzy Amplozy','1990-04-09',230,'Classical',null),
('HBPPMR83P08D310X','How my moma gonna die','2019-07-12',200,'Pop',null),
('HBPPMR83P08D310X','Fallen Castles','2018-01-10',200,'Pop',null),
('JPLRQP78C17A102B','Stupid crowds','2004-05-05',240,'Hip Hop',8),
('JPLRQP78C17A102B','Oh my lord..','2004-05-05',300,'Hip Hop',8),
('JPLRQP78C17A102B','Successor','2004-05-05',290,'Hip Hop',8);




insert into responsabile (codiceFiscale, nome, cognome, email, password, bdate, stipendio, idCasaDiscografica) values
('CFNCDR84S61B017N','Matteo','Noro','matteo.noro@studenti.unipd.it','@@XCC2#%2Pzer#Vc8A3#','2000-02-9',150000,1),
('SKDZDG85P10D051B','Mario','Rossi','mario.rossi@yahoo.it','4#QJvp98zqi!RGP3#QKm','1987-03-20',10000,2),
('ZJFDLP60B48I163W','Davide','Zanellato','davide.zanellato@gmail.com','@@XCC2#%2Pzer#Vc8A3#','1960-02-8',5000.43,3),
('PBHBGG66B45A579S','Beatrice','Stevanato','beatrice.stevanato@gmail.com','4NYGJ4@!&MG2kAU9$qPh','2003-04-1',15000,4),
('ZFCNPN59E15I187K','Nicola','Franceschi','nicola.franceschi@alice.it','@@XCC2#%2Pzer#Vc8A3#','1989-12-26',30000,5),
('TGTLDL98T08D889U','Larson','Brown','larsonbown@unibo.it','fhjskd//39286','1978-01-03',130000,6),
('WBLGVB58R23B029D','Wanda','Leichester','wandasaddy@gmail.com','wandiwandiiii23r4iyrw!!','1990-11-11',90000,7);


insert into cellulare (numero, codiceResponsabile) values
('4834406833','CFNCDR84S61B017N'),
('0078413293','CFNCDR84S61B017N'),
('7304109973','SKDZDG85P10D051B'),
('0721414795','ZJFDLP60B48I163W'),
('6428757194','PBHBGG66B45A579S'),
('9960868248','ZFCNPN59E15I187K'),
('7389279283','TGTLDL98T08D889U'),
('5739857543','TGTLDL98T08D889U'),
('0091230911','WBLGVB58R23B029D');


insert into concertoOnline (idCasaDiscografica, titoloConcerto, dataConcerto, prezzoBiglietto, numeroPostiMax) values 
(1,'Revival','2020-07-12',10.50,2000),
(1,'90 anni di Hip Hop','2020-11-11',12.50,6000),
(2,'Country style','2020-08-1',6.47,1500),
(4,'MarcoPippoeGaetano','2020-09-25',5,1700),
(5,'La caccia alle streghe','2020-10-30',20,8000),
(6,'SEE THAT CUTY FACE','2020-03-03',23,7890),
(6,'Pug 1800 evolution','2020-04-01',19,7890),
(7,'Bleeding hearts...','2020-04-12',34,6000),
(7,'How much pain','2021-01-01',30,6490);



insert into podcast (idCasaDiscografica, titoloPodcast, dataCaricamento, riassunto) values 
(1,'Filosofia di Pavel','2020-05-12','La “tradizione” marxista, per via delle sue origini, si è sempre concentrata sulla questione della produzione e dell’organizzazione: infatti, il suo luogo privilegiato di analisi della realtà (il luogo di produzione), le relazioni a cui presta attenzione (il modo di produzione), i suoi intenti politici e sociali (rivoluzione sociale) oltre che la priorità data a determinati fattori 
                                         (quelli materiali e strutturali su quelli immateriali e sovrastrutturali) ne hanno influenzato fortemente il corso della teoria e della pratica.'),
(2,'Italian indie','2018-12-25','Samuele Onelia intervista imprenditori che hanno avuto una notevole crescita, sia personale sia professionale, così da capire cosa ha funzionato maggiormente per loro, in modo da poterlo replicare. 
                                 L’archivio di Italian Indie conta ormai centinaia di interviste sui più svariati argomenti, insomma aggiungilo alla tua lista di risorse.'),
(3,'Marco montemagno Podcast','2017-10-07','Marco Montemagno tratta argomenti molto diversi tra di loro ma che sono di grande interesse per tutti coloro che desiderano migliorarsi a 360 gradi.
                                            Il podcast è la semplice versione audio di tutti i suoi video su YouTube, il mio consiglio è di sfogliare gli episodi con attenzione per trovare gli argomenti che ti interessano di più.'),
(4,'Talent Bay','2015-12-18','Talent Bay è un podcast fondato da Valerio Russo che si occupa di miglioramento personale, lavorativo e sportivo.
                              Valerio intervista gli Italiani che hanno raggiunto risultati rilevanti in ogni ambito, da quello sportivo a quello lavorativo per carpire abitudini, strategie e idee che hanno permesso loro di raggiungere risultati strabilianti.'),
(5,'La grande idea','2009-01-03','Max Formisano non necessita di presentazioni: è probabilmente il formatore Italiano più famoso del bel paese; l’intensità con cui si occupa di crescita personale è evidente nel suo podcast la grande idea.'),
(3,'Comunicare Convincere','1992-10-20',null);

insert into episodio (numeroEpisodio, idPodcast, titoloEpisodio, durata, descrizione) values
(1,1,'Marx e la sua vita',5454, 'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia'),
(2,1,'Marx e il suo pensiero',1450, 'La mia anima è pervasa da una mirabile serenità, simile a queste belle mattinate di maggio che io godo con tutto il cuore. Sono solo e mi rallegro di vivere in questo luogo che sembra esser creato per anime simili alla mia. Sono così felice, mio caro, così immerso nel sentimento della mia tranquilla'),
(3,1,'Riconoscimenti',120, null),
(1,2,'Storia del indie',6000,'Ma la volpe col suo balzo ha raggiunto il quieto Fido. Quel vituperabile xenofobo zelante assaggia il whisky ed esclama: alleluja! Aquel vituperable xenófobo apasionado prueba su güisqui y exclama: ¡Aleluya! Ma la volpe col suo balzo ha raggiunto il quieto Fido. Quel vituperabile xenofobo zelante as'),
(2,2,'Best of indie',500,'I migliori pezzi indie'),
(1,3,'Sono un pelato',15000,'Ma la volpe col suo balzo ha raggiunto il quieto Fido. Quel vituperabile xenofobo zelante assaggia il whisky ed esclama: alleluja! Aquel vituperable xenófobo apasionado prueba su güisqui y exclama: ¡Aleluya! Ma la volpe col suo balzo ha raggiunto il quieto Fido. Quel vituperabile xenofobo zelante assaggia il whisky ed esclama: alleluja! Aquel vituperable xenófobo apasionado prueba su güisqui y exc'),
(1,4,'I talenti migliori del 2020',8000,'Voglio dimostrare il rapporto estremamente dinamico che esiste tra il modo di produzione e le sue concretizzazioni storiche. Per farlo, ho bisogno innanzitutto di mettere in luce il rapporto tra mondo materiale oggettivo ed elemento intenzionale soggettivo, mostrando come l’elemento soggettivo (individuale o collettivo) non sia esclusivamente appendice del mondo oggettivo.'),
(1,5,'Apple non è una mela',547, null),
(1,6,'Vendimi questa penna',6589, 'Partendo dal mondo oggettivo, esso è essenzialmente l’insieme di condizioni nelle quali noi ci troviamo ad agire e i mezzi che ci sono pronti-alla-mano: pertanto è corretto ampliare la valenza di “oggettivo” anche a “sociale” oltre che a “materiale”, al quale spesso viene associato. Infatti, i rapporti sociali nei quali partecipiamo e i ruoli che ricopriamo sono ereditati, posti dal passato, nei quali siamo “gettati”, ed essi sono le condizioni che strutturano il nostro agire.'),
(2,6,'Vendimi il foglio',458, null);

insert into abbonato_playlist(codiceAbbonato, idPlaylist) values 
('PDSMLS33C54G392E',1),
('PDSMLS33C54G392E',2),
('TQRXSC51B61F004G',2),
('TQRXSC51B61F004G',4),
('KSMBVU77A06B812F',3),
('KSMBVU77A06B812F',1),
('KSMBVU77A06B812F',5),
('VMZLXK68H69C177C',4),
('VMZLXK68H69C177C',6),
('BHPVKV53R49G811Z',5),
('BHPVKV53R49G811Z',1),
('RGFYHP69S50H242Q',6),
('RGFYHP69S50H242Q',1),
('RJGSLW73R45D386Y',3),
('RJGSLW73R45D386Y',2),
('ZFVCHF67D49A551E',3),
('ZFVCHF67D49A551E',5),
('LWCRVF88D29A346Q',7),
('RCKTGC79M28Z611Y',8),
('NNZLHH81H55L290Q',9),
('VCDZYL54T65B644C',10),
('LWCRVF88D29A346Q',11),
('RGFYHP69S50H242Q',7),
('VMZLXK68H69C177C',8),
('LWCRVF88D29A346Q',8),
('TQRXSC51B61F004G',10),
('LWCRVF88D29A346Q',10),
('RJGSLW73R45D386Y',11);


insert into abbonato_episodio (codiceAbbonato, numeroEpisodio, idPodcast) values
('PDSMLS33C54G392E',1,1),
('PDSMLS33C54G392E',2,1),
('TQRXSC51B61F004G',2,2),
('TQRXSC51B61F004G',2,6),
('KSMBVU77A06B812F',1,6),
('KSMBVU77A06B812F',1,5),
('KSMBVU77A06B812F',1,4),
('VMZLXK68H69C177C',2,2),
('VMZLXK68H69C177C',3,1),
('BHPVKV53R49G811Z',1,1),
('BHPVKV53R49G811Z',2,6),
('RGFYHP69S50H242Q',2,2),
('RGFYHP69S50H242Q',1,2),
('RJGSLW73R45D386Y',2,1),
('RJGSLW73R45D386Y',1,1),
('ZFVCHF67D49A551E',1,5),
('ZFVCHF67D49A551E',1,1),
('RCKTGC79M28Z611Y',1,1),
('VCDZYL54T65B644C',1,6),
('LWCRVF88D29A346Q',2,2),
('NNZLHH81H55L290Q',2,1),
('RCKTGC79M28Z611Y',2,1),
('LWCRVF88D29A346Q',2,1);


insert into abbonato_concerto (codiceAbbonato, idConcerto, nPostoOccupato) values
('PDSMLS33C54G392E',1,23),
('PDSMLS33C54G392E',2,756),
('TQRXSC51B61F004G',3,1354),
('KSMBVU77A06B812F',4,822),
('KSMBVU77A06B812F',5,7045),
('VMZLXK68H69C177C',1,259),
('BHPVKV53R49G811Z',2,1450),
('RGFYHP69S50H242Q',2,5400),
('RJGSLW73R45D386Y',5,1000),
('ZFVCHF67D49A551E',3,177),
('ZFVCHF67D49A551E',4,966),
('LWCRVF88D29A346Q',6,999),
('LWCRVF88D29A346Q',7,731),
('NNZLHH81H55L290Q',6,201),
('NNZLHH81H55L290Q',9,274),
('VCDZYL54T65B644C',8,3001),
('VCDZYL54T65B644C',7,11);




insert into artista_canzone (codiceArtista, idCanzone, dataFeaturing) values
('RKRRRV63B59B376Q',6,'2018-12-24'),
('SSGRME81R21G922S',7,'2019-02-10'),
('VSXTLT77M43A855D',15,'2014-07-24'),
('HJLRTL83S12G430B',14,'2014-12-07'),
('FHVCNB86C19A741W',1,'2019-05-04'),
('QLLQRT86M18B051E',3,'2017-03-14'),
('VTNMPN34E48Z612K',10,'2015-02-06'),
('HKONSK94C58B914D',2,'2020-03-11'),
('HKONSK94C58B914D',5,'2016-02-5'),
('HKONSK94C58B914D',11,'2012-06-15'),
('VZJSBW42D14G415X',19,'1998-09-07'),
('VZJSBW42D14G415X',21,'1999-09-09'),
('HBPPMR83P08D310X',22,'1998-12-06');


insert into artista_concerto (codiceArtista, idConcerto) values 
('RKRRRV63B59B376Q',2),
('RKRRRV63B59B376Q',1),
('SSGRME81R21G922S',2),
('VSXTLT77M43A855D',2),
('VTNMPN34E48Z612K',2),
('SSGRME81R21G922S',4),
('QLLQRT86M18B051E',4),
('FHVCNB86C19A741W',2),
('FHVCNB86C19A741W',3),
('FHVCNB86C19A741W',5),
('HJLRTL83S12G430B',5),
('HJLRTL83S12G430B',4),
('HJLRTL83S12G430B',1),
('RZJPTF86C31C656C',6),
('RZJPTF86C31C656C',7),
('DDMZKS62B60I911X',8),
('JPLRQP78C17A102B',6),
('JPLRQP78C17A102B',7),
('DDMZKS62B60I911X',9);



insert into playlist_canzone (idPlaylist, idCanzone) values
(1,4),
(1,5),
(6,1),
(6,2),
(6,3),
(6,4),
(6,5),
(3,11),
(3,10),
(3,8),
(3,15),
(2,5),
(2,7),
(5,13),
(5,9),
(5,1),
(5,3),
(2,9),
(1,15),
(7,17),
(8,21),
(9,23),
(7,16),
(8,1),
(10,7),
(11,4),
(11,24),
(1,27),
(3,17),
(2,21),
(10,8),
(7,23),
(7,1),
(7,2),
(7,8),
(8,4),
(8,7),
(8,10);


alter table abbonato enable trigger all;
alter table playlist enable trigger all;
alter table casaDiscografica enable trigger all;
alter table artista enable trigger all;
alter table responsabile enable trigger all;
alter table cellulare enable trigger all;
alter table album enable trigger all;
alter table canzone enable trigger all;
alter table concertoOnline enable trigger all;
alter table podcast enable trigger all;
alter table episodio enable trigger all;
alter table abbonato_concerto enable trigger all;
alter table abbonato_playlist enable trigger all;
alter table abbonato_episodio enable trigger all;
alter table artista_concerto enable trigger all;
alter table artista_canzone enable trigger all;
alter table playlist_canzone enable trigger all;

/* INDICE */
drop index if exists ricerca_titoli_canzoni;
create index ricerca_titoli_canzoni on canzone(titoloCanzone);

/* QUERY */
/* 
    1. Trovare le 5 playlist pubbliche con più canzoni degli utenti
       Nati prima del 2000
*/
drop view if exists aux;
create view aux as 
select pl.idPlaylist
from playlist as pl
join abbonato as ab
on pl.codiceAbbonato = ab.codiceFiscale
where pl.isPubblica = true and bdate < '2000-01-01';

select nomePlaylist from playlist
where idPlaylist in (select idPlaylist from (select p_c.idPlaylist, count(p_c.idCanzone)
											 from playlist_canzone as p_c
											 join aux 
											 on aux.idPlaylist = p_c.idPlaylist
											 group by (p_c.idPlaylist)
											 order by count(p_c.idCanzone) desc 
											 limit 5) as tmp);

/*
    2. Abbonati maggiorenni che guardano un concerto in cui partecipa X artista seduti in posti dispari
*/
drop view if exists concerti_degli_artisti;
create view concerti_degli_artisti as 
select distinct co.idConcerto, co.titoloConcerto, ac.codiceArtista
from artista_concerto as ac
join concertoOnline as co
on ac.idConcerto = co.idConcerto
order by co.idConcerto; 


select *
from abbonato_concerto as abc
join concerti_degli_artisti as cdax
on abc.idConcerto = cdax.idConcerto
where abc.nPostoOccupato % 2 != 0 and cdax.codiceArtista = 'HJLRTL83S12G430B'
and exists (select *
		   	from abbonato as ab1
		   	where abc.codiceabbonato = ab1.codicefiscale
		   	and DATE_PART('year', current_date::date) - DATE_PART('year', ab1.bdate::date) > 18 );

/*
    3. Il/i podcast con l'episodio più ascoltato dagli abbonati
*/
drop view if exists episodi_maggiormente_ascoltati;
create view episodi_maggiormente_ascoltati as 
select ep.numeroEpisodio, ep.idPodcast, count(*) as quantity
from abbonato_episodio as ep
group by(ep.numeroEpisodio, ep.idPodcast);

select p.titolopodcast, ama.numeroEpisodio, ama.idpodcast
from episodi_maggiormente_ascoltati as ama
join podcast as p
on p.idpodcast = ama.idpodcast 
where quantity = (select max(quantity)
                 from episodi_maggiormente_ascoltati);

/*
    4. la casa discografica più ascoltata in termini di podcast e concerti
*/
drop view if exists ascolti_episodi;
create view ascolti_episodi as 
select ae.numeroEpisodio, ae.idPodcast, count(*) as ascolti
from abbonato_episodio as ae
group by (ae.numeroEpisodio, ae.idPodcast);

drop view if exists partecipanti_al_concerto;
create view partecipanti_al_concerto as 
select ac.idConcerto, count(*) as partecipanti
from abbonato_concerto as ac
group by (ac.idConcerto);

select tmp.nome, sum(tmp.ascoltiTot) as results
from ( 	select cd.nome, aep.ascolti as ascoltiTot 
	   	from ascolti_episodi as aep
		join podcast as p
		on p.idPodcast = aep.idPodcast
		join casaDiscografica as cd
		on cd.idCasa = p.idCasaDiscografica
		group by (cd.nome, aep.ascolti)
		union
		select cad.nome, pac.partecipanti as partecipantiTot
		from partecipanti_al_concerto as pac
		join concertoOnline as co
		on pac.idConcerto = co.idConcerto
		join casaDiscografica as cad
		on cad.idCasa = co.idCasaDiscografica
		group by (cad.nome, pac.partecipanti)) as tmp
group by (tmp.nome)
order by (results) desc limit 1;

/*
    5. trovare le case discografiche che hanno prodotto più di due 
       album hip hop e che hanno un dirigente che guadagna più di 5000 euro al mese.
*/
drop view if exists case_discografiche_con_album_hiphop;
create view case_discografiche_con_album_hiphop as 
select a.idCasaDiscografica, a.genereAlbum, count(*) as nalbum
from album as a 
where a.genereAlbum = 'Hip Hop'
group by (a.idCasaDiscografica, a.genereAlbum)
having a.idCasaDiscografica not in (select a2.idCasaDiscografica
								    from album as a2
								    where a2.genereAlbum != 'Hip Hop');

select cds.nome, cds.dataFondazione, cds.cap, cds.via, cds.numeroCivico
from case_discografiche_con_album_hiphop as cdh
join responsabile as r
on r.idCasaDiscografica = cdh.idCasaDiscografica
join casaDiscografica as cds
on cds.idCasa = cdh.idCasaDiscografica
where r.stipendio >= 5000 and cdh.nalbum >= 2;


/*
    6. Trovare gli artisti indipendenti (cioè che non sono affiliati a case discografiche) che hanno partecipato a dei featuring ma non ne hanno avuti
*/
select distinct art.codiceFiscale, art.nickname
from artista as art
join canzone as c
on c.codiceArtista = art.codiceFiscale
where art.idCasaDiscografica is null
	  and art.codiceFiscale in (select ac.codiceArtista
							    from artista_canzone as ac)
	  and c.idCanzone not in (select ac.idCanzone
							  from artista_canzone as ac);