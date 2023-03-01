(local highlight (require :highlight))
(local fennel (require :fennel.fennel))

(fn usage []
  (print "usage: highlight-cli.fnl [--from-lua] filename")
  (os.exit -1))

(var filename nil)
(var language :fennel)

(case arg
  [flag filename*] (do (if (= flag :--from-lua)
                          (set language :lua)
                          (usage))
                       (set filename filename*))
  [filename*] (set filename filename*)
  _ (usage))

(let [source-file (io.open filename :rb)
      source (source-file:read :*all)
      highlight-fn (case language
                     :fennel highlight.fennel->html
                     :lua highlight.lua->html)]
  (each [_ html (ipairs (highlight-fn (fennel.syntax) source))]
    (: io.stdout :write html)))
