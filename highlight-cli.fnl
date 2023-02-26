(local highlight (require :highlight))
(local fennel (require :fennel.fennel))

(local [filename] arg)

(when (not filename)
  (print "which file to highlight?")
  (os.exit -1))

(let [source-file (io.open filename :rb)
      source (source-file:read :*all)
      highlighted (highlight.for-html (fennel.syntax) source)]
  (print highlighted))
