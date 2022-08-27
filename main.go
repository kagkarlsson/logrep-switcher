package main

import (
	"context"
	"fmt"
	"github.com/jackc/pgx/v4"
	"os"
)

func main() {
	fmt.Println("Trying to connect")
	conn, err := pgx.Connect(context.Background(), "postgres://logrep:ia6JooHu5c@localhost:5433/logrep")
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to connect to database: %v\n", err)
		os.Exit(1)
	}
	defer conn.Close(context.Background())

	var id int64
	var value int64
	err = conn.QueryRow(context.Background(), "select id, value from test where id=$1", 1).Scan(&id, &value)
	if err != nil {
		fmt.Fprintf(os.Stderr, "QueryRow failed: %v\n", err)
		os.Exit(1)
	}

	fmt.Println(id, value)
}