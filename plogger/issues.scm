;; Plogger - Time tracking software
;; Copyright (C) 2010 Romel Raúl Sandoval-Palomo
;;
;; This program is free software; you can redistribute it and/or    
;; modify it under the terms of the GNU General Public License as   
;; published by the Free Software Foundation; either version 3 of   
;; the License, or (at your option) any later version.              
;;                                                                  
;; This program is distributed in the hope that it will be useful,  
;; but WITHOUT ANY WARRANTY; without even the implied warranty of   
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the    
;; GNU General Public License for more details.                     
;;                                                                  
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, contact:
;;
;; Free Software Foundation           Voice:  +1-617-542-5942
;; 59 Temple Place - Suite 330        Fax:    +1-617-542-2652
;; Boston, MA  02111-1307,  USA       gnu@gnu.org

(define-module (plogger issues)
  :use-module (plogger validations)
  :use-module (plogger projects)
  :use-module (plogger issue-types)
  :use-module (dbi dbi)
  :use-module (ice-9 format)
  :use-module (srfi srfi-16) ;case-lambda
  :export (new-issue get-issue-id update-issue-progress select-issues))

(define select-issues
  (case-lambda 
   ((db) 
    (dbi-query db "\
select p.title as Project, i.title as Issue, t.title as Type, \
i.progress as Progress from issues as i \
join projects as p on p.id = i.project_id \
join issue_types as t on t.id = i.type_id \
where i.progress < 100 
"))
   ((db project-title)
	(let ((project-id (get-project-id db project-title)))
	  (dbi-query db (format #f "\
select p.title as Project, i.title as Issue, t.title as Type, \
i.progress as Progress from issues as i \
join projects as p on p.id = i.project_id \
join issue_types as t on t.id = i.type_id \
where i.progress < 100 \
and project_id = ~d
"
							project-id))))
    ))

(define new-issue 
  (lambda (db type title project)
    (validate-string-length type 32)
    (validate-string-length title 32)
    (validate-string-length project 32)
    (let ((project-id (get-project-id db project))
	  (type-id (get-issue-type-id db type)))
      (dbi-query 
       db 
       (format #f "\
insert into issues (title, type_id, project_id) values ('~a', ~d , ~d )" 
	       title type-id project-id)))))

(define get-issue-id
  (lambda (db title project)
    (validate-string-length title 32)
    (validate-string-length project 32)
    (let ((project-id (get-project-id db project)))
      (dbi-query 
       db 
       (format #f 
	       "select id from issues where title = '~a' and project_id = ~d" 
	       title project-id))
      (cdr (assoc "id" (dbi-get_row db))))))

(define update-issue-progress
  (lambda (db issue-id issue-progress)
    (dbi-query 
     db (format 
	 #f (string-append "update issues set progress = ~3,2f "
			   "where id = ~d" )
	 issue-progress issue-id))))
