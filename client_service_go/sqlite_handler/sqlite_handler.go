// client_service_go/sqlite_handler/sqlite_handler.go

package sqlite_handler

import (
    "database/sql"
    "log"
    _ "github.com/mattn/go-sqlite3" // Import SQLite driver
)

// InitializeDB initializes an SQLite database and returns a database connection.
func InitializeDB() (*sql.DB, error) {
    db, err := sql.Open("sqlite3", "client_communication.db")
    if err != nil {
        return nil, err
    }

    // Create a table for storing communication records
    createTableSQL := `
        CREATE TABLE IF NOT EXISTS communication (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            service TEXT NOT NULL,
            message TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        );
    `
    _, err = db.Exec(createTableSQL)
    if err != nil {
        return nil, err
    }

    return db, nil
}

// StoreCommunication stores a communication record in the SQLite database.
func StoreCommunication(db *sql.DB, service, message string) error {
    insertSQL := "INSERT INTO communication (service, message) VALUES (?, ?)"
    _, err := db.Exec(insertSQL, service, message)
    if err != nil {
        log.Printf("Failed to store communication record in SQLite: %v", err)
        return err
    }
    return nil
}

// RetrieveCommunication retrieves communication records from the SQLite database.
func RetrieveCommunication(db *sql.DB) ([]CommunicationRecord, error) {
    query := "SELECT service, message, timestamp FROM communication ORDER BY timestamp ASC"
    rows, err := db.Query(query)
    if err != nil {
        log.Printf("Failed to retrieve communication records from SQLite: %v", err)
        return nil, err
    }
    defer rows.Close()

    var records []CommunicationRecord
    for rows.Next() {
        var record CommunicationRecord
        err := rows.Scan(&record.Service, &record.Message, &record.Timestamp)
        if err != nil {
            log.Printf("Error scanning communication record: %v", err)
            continue
        }
        records = append(records, record)
    }
    return records, nil
}

// CommunicationRecord represents a communication record in the database.
type CommunicationRecord struct {
    Service   string
    Message   string
    Timestamp string
}
