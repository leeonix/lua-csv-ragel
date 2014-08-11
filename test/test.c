
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <csv.h>

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

