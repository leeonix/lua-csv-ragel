/*
 * usage:
 * ragel -G2 csv.rl
 * gcc -o csv.exe csv.c -D__TEST__
 */

#include <stdio.h>
#include <string.h>
#include "csv.h"

#define BUFSIZE 4096

struct scanner {
    int cs;
    int act;
    char *ts;
    char *te;
    char *p;
    char *pe;
    char *eof;

    int done;
    int curline;
    char *data;
    int len;
    char buf[BUFSIZE];

	union {
		FILE *file;
		struct csv_buf {
			const char *buf;
			size_t len;
			size_t pos;
		} buf;
	} u;

	int (*do_read)(struct scanner *s, int space);
};

static int csv_file_read(struct scanner *s, int space)
{
    return fread(s->p, 1, space, s->u.file);
}

static int csv_buf_read(struct scanner *s, int space)
{
    if (s->u.buf.pos < s->u.buf.len) {
        memcpy(s->p, &s->u.buf.buf[s->u.buf.pos], space);
        s->u.buf.pos += space;
        return space;
    }
    printf("EOF: %d\n", EOF);
    return EOF;
}

%%{
    machine csv;

    variable p s->p;
    variable pe s->pe;
    variable eof s->eof;
    access s->;

    EOF = 0;
    EOL = [\r\n];
    comma = [,];
    string = [^,"\r\n\0]*;
    quote = '"' [^"\0]* '"';

    csv_scan := |*

    string => {
        return_token(TK_String);
        fbreak;
    };

    quote => {
        return_token(TK_Quote);
        s->data += 1;
        fbreak;
    };

    comma => {
        return_token(TK_Comma);
        fbreak;
    };

    EOL => {
        s->curline += 1;
        return_token(TK_EOL);
        fbreak;
    };

    EOF => {
        return_token(TK_EOF);
        fbreak;
    };

    *|;
}%%

%% write data nofinal;

static void
scan_init(struct scanner *s)
{
    memset(s, 0, sizeof(struct scanner));
    s->curline = 1;
    %% write init;
}

static int
check_buf(struct scanner *s)
{
    int have, space, readlen;

    if (s->p == s->pe) {
        if (s->ts == 0) {
            have = 0;
        } else {
            have = s->pe - s->ts;
            memmove(s->buf, s->ts, have);
            s->te -= (s->ts - s->buf);
            s->ts = s->buf;
        }

        s->p = s->buf + have;
        space = BUFSIZE - have;

        if (space == 0) {
            return TK_ERR;
        }

        if (s->done) {
            s->p[0] = 0;
            readlen = 1;
        } else {
            readlen = s->do_read(s, space);
            if (readlen < space) {
                s->done = 1;
            }
        }

        s->pe = s->p + readlen;
    }
    return 0;
}

#define return_token(t) token = t; s->data = s->ts

static int
scan(struct scanner *s)
{
    int token = 0;

    while (1) {
        if (check_buf(s) == TK_ERR) {
            return TK_ERR;
        }

        %% write exec;

        if (s->cs == csv_error) {
            return TK_ERR;
        }

        if (token < 0) {
            switch (token) {
            case TK_Quote:
                s->len = s->p - s->data - 1;
                break;
            case TK_String:
                s->len = s->p - s->data;
                break;
            }               // -----  end switch  -----
            return token;
        }
    }
}

static void
csv_read(struct scanner *s, csv_fn_t fn)
{
    while (1) {
        int token = scan(s);
        switch (token) {
        case TK_Quote:
        case TK_String:
            fn(token, s->curline, s->data, s->len);
            break;
        default:
            fn(token, s->curline, NULL, 0);
            if (token == TK_ERR || token == TK_EOF) {
                return;
            }
        }               // -----  end switch  -----
    }
}

void
csv_fread(csv_fn_t fn, FILE *f)
{
    struct scanner s;
    scan_init(&s);
    s.u.file = f;
    s.do_read = csv_file_read;
    csv_read(&s, fn);
}

void
csv_read_file(csv_fn_t fn, const char *name)
{
    FILE *f = fopen(name, "r");
    if (f != NULL) {
        csv_fread(fn, f);
        fclose(f);
    }
}

void
csv_read_buf(csv_fn_t fn, const char *buf, size_t len)
{
    struct scanner s;
    scan_init(&s);
    s.u.buf.buf = buf;
    s.u.buf.len = len;
    s.do_read = csv_buf_read;
    csv_read(&s, fn);
}

#ifdef __TEST__

#include <malloc.h>

static void
read_csv_file(int token, int record_no, const char *field, int field_len)
{
    printf("line: %04d ", record_no);
    switch (token) {
    case TK_ERR:
        printf("ERR\n");
        break;
    case TK_EOF:
        printf("EOF\n");
        break;
    case TK_EOL:
        printf("EOL\n");
        break;
    case TK_Comma:
        printf("Comma\n");
        break;
    case TK_Quote:
        printf("Quote \"");
        fwrite(field, 1, field_len, stdout);
        printf("\"\n");
        break;
    case TK_String:
        printf("String \"");
        fwrite(field, 1, field_len, stdout);
        printf("\"\n");
        break;
    }               // -----  end switch  -----
}

static void
read_buf(FILE *f)
{
    char *buf;
    size_t len;

    fseek(f, 0, SEEK_END);
    len = ftell(f);
    fprintf(stderr, "len: %d\n", (int)len);
    fseek(f, 0, SEEK_SET);
    buf = malloc(len + 1);
    memset(buf, 0, len + 1);
    len = fread(buf, len, 1, f);

    csv_read_buf(read_csv_file, buf, len);
    free(buf);
}

static void
read_file_buf(const char *name)
{
    FILE *f = fopen(name, "r");
    if (f != NULL) {
        read_buf(f);
        fclose(f);
    }
}

int
main(int argc, char *argv[])
{
    if (argc > 1) {
        csv_read_file(read_csv_file, argv[1]);
        read_file_buf(argv[1]);
    } else {
        csv_fread(read_csv_file, stdin);
        read_buf(stdin);
    }

    return 0;
}

#endif

