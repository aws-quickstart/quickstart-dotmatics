// @author Laurent Krishnathas
// @year 2018/06/08

package main

import (
	"log"
	"net/http"
	"os"
)

const default_port = "8080"
const default_url = "/browser"

type Server struct {
	url string
}

func (server *Server) redirect(w http.ResponseWriter, req *http.Request) {
	target := server.url + req.URL.Path
	if len(req.URL.RawQuery) > 0 {
		target += "?" + req.URL.RawQuery
	}
	log.Printf("redirect to: %s ...", target)
	http.Redirect(w, req, target, http.StatusMovedPermanently)
}

func main() {
	log.Printf("starting ...")

	port := os.Getenv("PORT")
	if port == "" {
		port = default_port
	}
	log.Printf("port set to %s", port)

	server := &Server{url: os.Getenv("REDIRECT_URL")}
	if server.url == "" {
		server.url = default_url
	}
	log.Printf("redirect url set to %s", server.url)

	log.Printf("listening on %s ...", port)
	if err := http.ListenAndServe(":"+port, http.HandlerFunc(server.redirect)); err != nil {
		panic(err)
	}
}